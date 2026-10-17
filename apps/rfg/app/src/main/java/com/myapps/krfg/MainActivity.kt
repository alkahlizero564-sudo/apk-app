package com.myapps.krfg

import android.app.Activity
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.StateListDrawable
import android.os.Bundle
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.*
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.text.DecimalFormat
import java.text.DecimalFormatSymbols
import java.util.Locale

class MainActivity : Activity() {

    private lateinit var tvExpression: TextView
    private lateinit var tvResult: TextView
    private lateinit var historyLayout: LinearLayout
    private lateinit var historyListView: ListView
    private lateinit var historyAdapter: ArrayAdapter<String>
    private val historyItems = ArrayList<String>()

    private lateinit var prefs: SharedPreferences

    private var currentInput = StringBuilder()
    private var firstOperand: Double? = null
    private var pendingOperator: String? = null
    private var isNewOperation = true

    private val decimalFormat = DecimalFormat("#,###.########", DecimalFormatSymbols(Locale.US))

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        prefs = getSharedPreferences("CalculatorPrefs", Context.MODE_PRIVATE)
        loadHistory()

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.parseColor("#12131A"))
            layoutDirection = View.LAYOUT_DIRECTION_RTL
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            setPadding(dp(16), dp(16), dp(16), dp(16))
        }

        // Top Bar
        val topBar = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = dp(8)
            }
        }

        val tvTitle = TextView(this).apply {
            text = "آلة حاسبة ذكية"
            setTextColor(Color.parseColor("#E0E0E6"))
            textSize = 20f
            typeface = Typeface.DEFAULT_BOLD
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
        }

        val btnOnlineRate = createActionButton("تحويل عملة (USD)") {
            fetchOnlineRate()
        }

        val btnToggleHistory = createActionButton("السجل") {
            toggleHistoryView()
        }

        topBar.addView(tvTitle)
        topBar.addView(btnOnlineRate)
        topBar.addView(btnToggleHistory)
        root.addView(topBar)

        // History View Panel (Initially Collapsed)
        historyLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            visibility = View.GONE
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                dp(180)
            ).apply {
                bottomMargin = dp(8)
            }
            background = createRoundedDrawable(Color.parseColor("#1B1C26"), 16f)
            setPadding(dp(10), dp(10), dp(10), dp(10))
        }

        val historyHeader = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }

        val tvHistoryTitle = TextView(this).apply {
            text = "سجل العمليات"
            setTextColor(Color.parseColor("#A0A0B0"))
            textSize = 14f
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
        }

        val btnClearHistory = TextView(this).apply {
            text = "مسح"
            setTextColor(Color.parseColor("#FF5C5C"))
            textSize = 14f
            typeface = Typeface.DEFAULT_BOLD
            setPadding(dp(8), dp(4), dp(8), dp(4))
            setOnClickListener {
                historyItems.clear()
                historyAdapter.notifyDataSetChanged()
                saveHistory()
            }
        }

        historyHeader.addView(tvHistoryTitle)
        historyHeader.addView(btnClearHistory)
        historyLayout.addView(historyHeader)

        historyListView = ListView(this).apply {
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            divider = null
        }

        historyAdapter = object : ArrayAdapter<String>(this, android.R.layout.simple_list_item_1, historyItems) {
            override fun getView(position: Int, convertView: View?, parent: ViewGroup): View {
                val view = super.getView(position, convertView, parent) as TextView
                view.setTextColor(Color.parseColor("#CCCCCC"))
                view.textSize = 14f
                view.gravity = Gravity.START or Gravity.CENTER_VERTICAL
                return view
            }
        }
        historyListView.adapter = historyAdapter
        historyLayout.addView(historyListView)
        root.addView(historyLayout)

        // Display Screen
        val displayContainer = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.BOTTOM or Gravity.END
            background = createRoundedDrawable(Color.parseColor("#1A1B24"), 20f)
            setPadding(dp(20), dp(20), dp(20), dp(20))
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                0,
                1.3f
            ).apply {
                bottomMargin = dp(16)
            }
        }

        tvExpression = TextView(this).apply {
            textSize = 18f
            setTextColor(Color.parseColor("#8E8E9F"))
            gravity = Gravity.END
            typeface = Typeface.DEFAULT
            maxLines = 1
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }

        tvResult = TextView(this).apply {
            text = "0"
            textSize = 42f
            setTextColor(Color.WHITE)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.END
            maxLines = 1
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }

        displayContainer.addView(tvExpression)
        displayContainer.addView(tvResult)
        root.addView(displayContainer)

        // Keypad Grid
        val keypadContainer = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                0,
                3.2f
            )
        }

        val buttons = arrayOf(
            arrayOf("C", "⌫", "%", "÷"),
            arrayOf("7", "8", "9", "×"),
            arrayOf("4", "5", "6", "-"),
            arrayOf("1", "2", "3", "+"),
            arrayOf("±", "0", ".", "=")
        )

        for (row in buttons) {
            val rowLayout = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    0,
                    1f
                )
            }

            for (btnText in row) {
                val button = createCalculatorButton(btnText)
                rowLayout.addView(button)
            }
            keypadContainer.addView(rowLayout)
        }

        root.addView(keypadContainer)
        setContentView(root)
    }

    private fun createCalculatorButton(text: String): View {
        val frame = FrameLayout(this).apply {
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, 1f).apply {
                setMargins(dp(4), dp(4), dp(4), dp(4))
            }
        }

        val btn = Button(this).apply {
            this.text = text
            isAllCaps = false
            typeface = Typeface.DEFAULT_BOLD
            textSize = 22f
            layoutParams = FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )

            val (bgColor, pressedColor, textColor) = when (text) {
                "=", "÷", "×", "-", "+" -> Triple("#3F51B5", "#303F9F", "#FFFFFF")
                "C", "⌫" -> Triple("#D32F2F", "#B71C1C", "#FFFFFF")
                "%", "±" -> Triple("#2D2F3F", "#3D4155", "#82B1FF")
                else -> Triple("#232430", "#323445", "#F0F0F5")
            }

            setTextColor(Color.parseColor(textColor))
            background = createRippleDrawable(
                Color.parseColor(bgColor),
                Color.parseColor(pressedColor),
                22f
            )

            setOnClickListener { onKeyClicked(text) }
        }

        frame.addView(btn)
        return frame
    }

    private fun createActionButton(label: String, onClick: () -> Unit): Button {
        return Button(this).apply {
            text = label
            textSize = 12f
            isAllCaps = false
            setTextColor(Color.parseColor("#B0B3C6"))
            background = createRippleDrawable(Color.parseColor("#252736"), Color.parseColor("#34384D"), 14f)
            setPadding(dp(10), dp(4), dp(10), dp(4))
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                dp(36)
            ).apply {
                marginStart = dp(6)
            }
            setOnClickListener { onClick() }
        }
    }

    private fun onKeyClicked(key: String) {
        when (key) {
            "C" -> clearAll()
            "⌫" -> backspace()
            "±" -> toggleSign()
            "%" -> calculatePercentage()
            "+", "-", "×", "÷" -> setOperator(key)
            "=" -> calculateResult()
            "." -> appendDot()
            else -> appendDigit(key)
        }
    }

    private fun appendDigit(digit: String) {
        if (isNewOperation) {
            currentInput.clear()
            isNewOperation = false
        }
        if (currentInput.length < 15) {
            currentInput.append(digit)
            tvResult.text = currentInput.toString()
        }
    }

    private fun appendDot() {
        if (isNewOperation) {
            currentInput.clear()
            currentInput.append("0")
            isNewOperation = false
        }
        if (!currentInput.contains(".")) {
            if (currentInput.isEmpty()) {
                currentInput.append("0")
            }
            currentInput.append(".")
            tvResult.text = currentInput.toString()
        }
    }

    private fun toggleSign() {
        if (currentInput.isNotEmpty()) {
            val value = currentInput.toString().toDoubleOrNull() ?: return
            val toggled = -value
            currentInput.clear()
            currentInput.append(formatNumber(toggled))
            tvResult.text = currentInput.toString()
        }
    }

    private fun calculatePercentage() {
        if (currentInput.isNotEmpty()) {
            val value = currentInput.toString().toDoubleOrNull() ?: return
            val result = value / 100.0
            currentInput.clear()
            currentInput.append(formatNumber(result))
            tvResult.text = currentInput.toString()
        }
    }

    private fun setOperator(operator: String) {
        val currentVal = currentInput.toString().toDoubleOrNull()
        if (firstOperand == null && currentVal != null) {
            firstOperand = currentVal
            pendingOperator = operator
            tvExpression.text = "${formatNumber(currentVal)} $operator"
            isNewOperation = true
        } else if (firstOperand != null && currentVal != null && !isNewOperation) {
            executePendingOperation(currentVal)
            pendingOperator = operator
            tvExpression.text = "${formatNumber(firstOperand!!)} $operator"
            isNewOperation = true
        } else {
            pendingOperator = operator
            if (firstOperand != null) {
                tvExpression.text = "${formatNumber(firstOperand!!)} $operator"
            }
        }
    }

    private fun executePendingOperation(secondOperand: Double) {
        val op = pendingOperator ?: return
        val first = firstOperand ?: return

        val result = when (op) {
            "+" -> first + secondOperand
            "-" -> first - secondOperand
            "×" -> first * secondOperand
            "÷" -> {
                if (secondOperand == 0.0) {
                    Toast.makeText(this, "لا يمكن القسمة على صفر", Toast.LENGTH_SHORT).show()
                    return
                }
                first / secondOperand
            }
            else -> secondOperand
        }

        firstOperand = result
        tvResult.text = formatNumber(result)
    }

    private fun calculateResult() {
        val secondOperand = currentInput.toString().toDoubleOrNull()
        val first = firstOperand
        val op = pendingOperator

        if (first != null && secondOperand != null && op != null) {
            if (op == "÷" && secondOperand == 0.0) {
                Toast.makeText(this, "لا يمكن القسمة على صفر", Toast.LENGTH_SHORT).show()
                return
            }

            val result = when (op) {
                "+" -> first + secondOperand
                "-" -> first - secondOperand
                "×" -> first * secondOperand
                "÷" -> first / secondOperand
                else -> secondOperand
            }

            val historyEntry = "${formatNumber(first)} $op ${formatNumber(secondOperand)} = ${formatNumber(result)}"
            addHistory(historyEntry)

            tvExpression.text = historyEntry
            tvResult.text = formatNumber(result)

            currentInput.clear()
            currentInput.append(formatNumber(result))
            firstOperand = null
            pendingOperator = null
            isNewOperation = true
        }
    }

    private fun clearAll() {
        currentInput.clear()
        firstOperand = null
        pendingOperator = null
        isNewOperation = true
        tvExpression.text = ""
        tvResult.text = "0"
    }

    private fun backspace() {
        if (!isNewOperation && currentInput.isNotEmpty()) {
            currentInput.deleteCharAt(currentInput.length - 1)
            tvResult.text = if (currentInput.isEmpty()) "0" else currentInput.toString()
        }
    }

    private fun formatNumber(value: Double): String {
        return if (value % 1.0 == 0.0) {
            value.toLong().toString()
        } else {
            decimalFormat.format(value)
        }
    }

    private fun toggleHistoryView() {
        historyLayout.visibility = if (historyLayout.visibility == View.VISIBLE) View.GONE else View.VISIBLE
    }

    private fun addHistory(entry: String) {
        historyItems.add(0, entry)
        if (historyItems.size > 20) historyItems.removeAt(historyItems.size - 1)
        historyAdapter.notifyDataSetChanged()
        saveHistory()
    }

    private fun saveHistory() {
        val set = historyItems.joinToString(";;;")
        prefs.edit().putString("calc_history", set).apply()
    }

    private fun loadHistory() {
        val saved = prefs.getString("calc_history", "") ?: ""
        if (saved.isNotEmpty()) {
            historyItems.addAll(saved.split(";;;"))
        }
    }

    private fun fetchOnlineRate() {
        Toast.makeText(this, "جاري جلب سعر الصرف...", Toast.LENGTH_SHORT).show()
        Thread {
            try {
                val url = URL("https://api.frankfurter.app/latest?from=USD&to=SAR")
                val conn = url.openConnection() as HttpURLConnection
                conn.requestMethod = "GET"
                conn.connectTimeout = 4000
                conn.readTimeout = 4000

                if (conn.responseCode == 200) {
                    val reader = BufferedReader(InputStreamReader(conn.inputStream))
                    val response = StringBuilder()
                    var line: String?
                    while (reader.readLine().also { line = it } != null) {
                        response.append(line)
                    }
                    reader.close()

                    // Parse rate manually to avoid external JSON parser
                    val text = response.toString()
                    val target = "\"SAR\":"
                    val index = text.indexOf(target)
                    if (index != -1) {
                        val sub = text.substring(index + target.length)
                        val rateStr = sub.substringBefore("}").trim()
                        val rate = rateStr.toDoubleOrNull() ?: 3.75

                        runOnUiThread {
                            currentInput.clear()
                            currentInput.append(formatNumber(rate))
                            tvResult.text = currentInput.toString()
                            tvExpression.text = "1 USD = $rate SAR"
                            isNewOperation = true
                            Toast.makeText(this@MainActivity, "تم تحديث سعر الدولار إلى الريال", Toast.LENGTH_SHORT).show()
                        }
                    }
                } else {
                    runOnUiThread {
                        fallbackRate()
                    }
                }
                conn.disconnect()
            } catch (e: Exception) {
                runOnUiThread {
                    fallbackRate()
                }
            }
        }.start()
    }

    private fun fallbackRate() {
        val defaultRate = 3.75
        currentInput.clear()
        currentInput.append(formatNumber(defaultRate))
        tvResult.text = currentInput.toString()
        tvExpression.text = "سعر تقريبي: 1 USD = 3.75 SAR"
        isNewOperation = true
        Toast.makeText(this, "تم وضع السعر التقريبي (3.75)", Toast.LENGTH_SHORT).show()
    }

    private fun createRoundedDrawable(color: Int, radiusDp: Float): GradientDrawable {
        return GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            setColor(color)
            cornerRadius = dp(radiusDp).toFloat()
        }
    }

    private fun createRippleDrawable(normalColor: Int, pressedColor: Int, radiusDp: Float): StateListDrawable {
        val stateList = StateListDrawable()
        val pressedDrawable = createRoundedDrawable(pressedColor, radiusDp)
        val normalDrawable = createRoundedDrawable(normalColor, radiusDp)
        stateList.addState(intArrayOf(android.R.attr.state_pressed), pressedDrawable)
        stateList.addState(intArrayOf(), normalDrawable)
        return stateList
    }

    private fun dp(value: Int): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            value.toFloat(),
            resources.displayMetrics
        ).toInt()
    }

    private fun dp(value: Float): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            value,
            resources.displayMetrics
        ).toInt()
    }
}
