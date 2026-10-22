import json
import certifi
from kivy.app import App
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.label import Label
from kivy.uix.textinput import TextInput
from kivy.uix.button import Button
from kivy.uix.spinner import Spinner
from kivy.uix.scrollview import ScrollView
from kivy.graphics import Color, RoundedRectangle, Rectangle
from kivy.clock import Clock
from kivy.core.window import Window
from kivy.animation import Animation
from kivy.network.urlrequest import UrlRequest

PRIMARY_COLOR = (0.058, 0.462, 0.431, 1)
SECONDARY_COLOR = (0.035, 0.325, 0.298, 1)
BG_COLOR = (0.95, 0.96, 0.97, 1)
WHITE = (1, 1, 1, 1)
GRAY_TEXT = (0.3, 0.3, 0.3, 1)
ERROR_COLOR = (0.8, 0.2, 0.2, 1)
SUCCESS_COLOR = (0.1, 0.6, 0.3, 1)

SUPABASE_URL = "https://qlvmxnoewxzykgbneadv.supabase.co/rest/v1/orders"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFsdm14bm9ld3h6eWtnYm5lYWR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE2NDAwMjIsImV4cCI6MjEwNzIxNjAyMn0.WtsiO0PrUrwxKjpcyB3949kXSZeijtlJYySSbh0ieRk"

class RoundedButton(Button):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.background_color = (0, 0, 0, 0)
        self.color = WHITE
        self.font_size = '18sp'
        self.bold = True
        self.bind(pos=self.update_canvas, size=self.update_canvas)

    def update_canvas(self, *args):
        self.canvas.before.clear()
        with self.canvas.before:
            Color(*PRIMARY_COLOR)
            self.rect = RoundedRectangle(pos=self.pos, size=self.size, radius=[16])

class CardLayout(BoxLayout):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.orientation = 'vertical'
        self.padding = 20
        self.spacing = 15
        self.bind(pos=self.update_canvas, size=self.update_canvas)

    def update_canvas(self, *args):
        self.canvas.before.clear()
        with self.canvas.before:
            Color(1, 1, 1, 1)
            self.rect = RoundedRectangle(pos=self.pos, size=self.size, radius=[20])

class OrderScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        
        with self.canvas.before:
            Color(*BG_COLOR)
            self.bg_rect = Rectangle(size=Window.size, pos=self.pos)
        self.bind(size=self._update_bg, pos=self._update_bg)

        root_layout = BoxLayout(orientation='vertical', padding=20, spacing=15)
        
        header_layout = BoxLayout(orientation='vertical', size_hint_y=None, height=80, spacing=5)
        title_label = Label(
            text='تطبيق حجز العيش السوداني',
            font_size='24sp',
            bold=True,
            color=PRIMARY_COLOR,
            halign='center',
            valign='middle'
        )
        title_label.bind(size=title_label.setter('text_size'))
        
        subtitle_label = Label(
            text='أدخل بيانات طلبك بدقة لإرساله مباشرة',
            font_size='14sp',
            color=GRAY_TEXT,
            halign='center',
            valign='middle'
        )
        subtitle_label.bind(size=subtitle_label.setter('text_size'))
        
        header_layout.add_widget(title_label)
        header_layout.add_widget(subtitle_label)
        root_layout.add_widget(header_layout)

        scroll = ScrollView(size_hint=(1, 1))
        card = CardLayout(size_hint_y=None)
        card.bind(minimum_height=card.setter('height'))

        card.add_widget(Label(text='اسم المتبوع / الموظف:', font_size='14sp', color=GRAY_TEXT, size_hint_y=None, height=25, halign='right'))
        self.name_input = TextInput(
            hint_text='أدخل اسمك الثلاثي',
            multiline=False,
            size_hint_y=None,
            height=50,
            font_size='16sp',
            padding=[15, 12]
        )
        card.add_widget(self.name_input)

        card.add_widget(Label(text='رقم الهاتف السوداني:', font_size='14sp', color=GRAY_TEXT, size_hint_y=None, height=25, halign='right'))
        self.phone_input = TextInput(
            hint_text='09xxxxxxxx',
            multiline=False,
            input_type='tel',
            size_hint_y=None,
            height=50,
            font_size='16sp',
            padding=[15, 12]
        )
        card.add_widget(self.phone_input)

        card.add_widget(Label(text='الكمية المطلوبة (بالجنيه السوداني):', font_size='14sp', color=GRAY_TEXT, size_hint_y=None, height=25, halign='right'))
        self.amount_input = TextInput(
            hint_text='مثال: 5000',
            multiline=False,
            input_type='number',
            size_hint_y=None,
            height=50,
            font_size='16sp',
            padding=[15, 12]
        )
        card.add_widget(self.amount_input)

        card.add_widget(Label(text='طريقة الدفع:', font_size='14sp', color=GRAY_TEXT, size_hint_y=None, height=25, halign='right'))
        self.payment_spinner = Spinner(
            text='نقدي',
            values=('نقدي', 'أجل'),
            size_hint_y=None,
            height=50,
            font_size='16sp'
        )
        card.add_widget(self.payment_spinner)

        card.add_widget(Label(text='مكان العمل / الفرع:', font_size='14sp', color=GRAY_TEXT, size_hint_y=None, height=25, halign='right'))
        self.workplace_input = TextInput(
            hint_text='مثال: الخرطوم - الإدارة العامة',
            multiline=False,
            size_hint_y=None,
            height=50,
            font_size='16sp',
            padding=[15, 12]
        )
        card.add_widget(self.workplace_input)

        card.add_widget(Label(size_hint_y=None, height=10))

        self.submit_btn = RoundedButton(
            text='إرسال الطلب الآن',
            size_hint_y=None,
            height=56
        )
        self.submit_btn.bind(on_press=self.submit_order)
        card.add_widget(self.submit_btn)

        self.status_label = Label(
            text='',
            font_size='14sp',
            size_hint_y=None,
            height=30,
            halign='center'
        )
        card.add_widget(self.status_label)

        scroll.add_widget(card)
        root_layout.add_widget(scroll)
        self.add_widget(root_layout)

        Clock.schedule_interval(self.fetch_orders, 5)

    def _update_bg(self, instance, value):
        self.bg_rect.pos = instance.pos
        self.bg_rect.size = instance.size

    def fetch_orders(self, dt):
        headers = {
            "apikey": SUPABASE_KEY,
            "Authorization": f"Bearer {SUPABASE_KEY}",
            "Content-Type": "application/json"
        }
        try:
            UrlRequest(
                SUPABASE_URL,
                req_headers=headers,
                ca_file=certifi.where(),
                on_success=self.on_fetch_success,
                on_error=self.on_fetch_error,
                on_failure=self.on_fetch_error
            )
        except Exception:
            pass

    def on_fetch_success(self, request, result):
        pass

    def on_fetch_error(self, request, error):
        pass

    def submit_order(self, instance):
        name = self.name_input.text.strip()
        phone = self.phone_input.text.strip()
        amount_str = self.amount_input.text.strip()
        payment_type = self.payment_spinner.text
        workplace = self.workplace_input.text.strip()

        if not name or not phone or not amount_str or not workplace:
            self.status_label.text = '⚠️ الرجاء تعبئة جميع الحقول المطلوبة'
            self.status_label.color = ERROR_COLOR
            self._animate_error()
            return

        if not phone.startswith('09') or len(phone) != 10:
            self.status_label.text = '⚠️ رقم الهاتف السوداني غير صحيح (يجب أن يبدأ بـ 09)'
            self.status_label.color = ERROR_COLOR
            self._animate_error()
            return

        try:
            amount = float(amount_str)
        except ValueError:
            self.status_label.text = '⚠️ المبلغ يجب أن يكون رقماً صحيحاً'
            self.status_label.color = ERROR_COLOR
            self._animate_error()
            return

        order_data = {
            'name': name,
            'phone': phone,
            'amount': amount,
            'payment_type': payment_type,
            'workplace': workplace
        }

        headers = {
            "apikey": SUPABASE_KEY,
            "Authorization": f"Bearer {SUPABASE_KEY}",
            "Content-Type": "application/json",
            "Prefer": "return=representation"
        }

        try:
            UrlRequest(
                SUPABASE_URL,
                req_headers=headers,
                req_body=json.dumps(order_data),
                method='POST',
                ca_file=certifi.where(),
                on_success=self.on_submit_success,
                on_error=self.on_submit_error,
                on_failure=self.on_submit_error
            )
        except Exception:
            self.status_label.text = '⚠️ حدث خطأ في الاتصال بالإنترنت'
            self.status_label.color = ERROR_COLOR

    def on_submit_success(self, request, result):
        self.status_label.text = '✅ تم إرسال طلبك بنجاح إلى النظام المشترك!'
        self.status_label.color = SUCCESS_COLOR
        
        self.name_input.text = ''
        self.phone_input.text = ''
        self.amount_input.text = ''
        self.workplace_input.text = ''

        anim = Animation(background_color=(0.1, 0.8, 0.4, 1), duration=0.2) + Animation(background_color=PRIMARY_COLOR, duration=0.2)
        anim.start(self.submit_btn)

    def on_submit_error(self, request, error):
        self.status_label.text = '⚠️ فشل إرسال الطلب، تأكد من الاتصال بالإنترنت'
        self.status_label.color = ERROR_COLOR
        self._animate_error()

    def _animate_error(self):
        anim = Animation(x=self.x - 10, duration=0.05) + Animation(x=self.x + 20, duration=0.05) + Animation(x=self.x, duration=0.05)
        anim.start(self.submit_btn)

class BreadOrderApp(App):
    def build(self):
        self.title = 'حجز العيش السوداني'
        sm = ScreenManager()
        sm.add_widget(OrderScreen(name='order'))
        return sm

if __name__ == '__main__':
    BreadOrderApp().run()