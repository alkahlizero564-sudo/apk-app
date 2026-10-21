<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>مهامي اليومية</title>
  <style>
    :root {
      --primary: #4f46e5;
      --primary-dark: #3730a3;
      --primary-light: #e0e7ff;
      --accent: #06b6d4;
      --success: #10b981;
      --warning: #f59e0b;
      --danger: #ef4444;
      --bg: #f8fafc;
      --surface: #ffffff;
      --text: #0f172a;
      --text-muted: #64748b;
      --border: #e2e8f0;
      --radius: 18px;
      --radius-sm: 10px;
      --shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.05), 0 8px 10px -6px rgba(0, 0, 0, 0.03);
      --shadow-lg: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
      -webkit-tap-highlight-color: transparent;
      user-select: none;
    }

    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Cairo", Tahoma, sans-serif;
      background-color: var(--bg);
      color: var(--text);
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      overflow-x: hidden;
      padding-bottom: 90px;
    }

    header {
      background: linear-gradient(135deg, var(--primary), #6366f1);
      color: white;
      padding: 24px 20px 30px;
      border-radius: 0 0 32px 32px;
      box-shadow: 0 10px 20px rgba(79, 70, 229, 0.2);
    }

    .header-top {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 15px;
    }

    .app-title {
      font-size: 24px;
      font-weight: 800;
      letter-spacing: -0.5px;
    }

    .today-date {
      font-size: 13px;
      background: rgba(255, 255, 255, 0.2);
      padding: 6px 14px;
      border-radius: 20px;
      backdrop-filter: blur(5px);
      font-weight: 600;
    }

    /* شريط التقدم اليومي */
    .progress-card {
      background: rgba(255, 255, 255, 0.15);
      backdrop-filter: blur(10px);
      border-radius: var(--radius);
      padding: 16px 20px;
      display: flex;
      align-items: center;
      gap: 16px;
      border: 1px solid rgba(255, 255, 255, 0.25);
    }

    .progress-info {
      flex: 1;
    }

    .progress-label {
      font-size: 13px;
      margin-bottom: 6px;
      opacity: 0.9;
    }

    .progress-bar-bg {
      height: 10px;
      background: rgba(255, 255, 255, 0.3);
      border-radius: 10px;
      overflow: hidden;
    }

    .progress-bar-fill {
      height: 100%;
      background: #34d399;
      width: 0%;
      transition: width 0.4s ease;
      border-radius: 10px;
    }

    .progress-percent {
      font-size: 20px;
      font-weight: 800;
      min-width: 48px;
      text-align: left;
    }

    /* تصنيفات وتصفية */
    .filters-wrap {
      padding: 16px 20px 4px;
      display: flex;
      gap: 8px;
      overflow-x: auto;
      scrollbar-width: none;
    }
    .filters-wrap::-webkit-scrollbar { display: none; }

    .filter-chip {
      background: var(--surface);
      color: var(--text-muted);
      border: 1px solid var(--border);
      padding: 10px 18px;
      border-radius: 30px;
      font-size: 14px;
      font-weight: 600;
      white-space: nowrap;
      cursor: pointer;
      transition: all 0.2s ease;
    }

    .filter-chip.active {
      background: var(--primary);
      color: #fff;
      border-color: var(--primary);
      box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3);
    }

    /* قائمة المهام */
    .task-container {
      padding: 16px 20px;
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 12px;
    }

    .task-item {
      background: var(--surface);
      border-radius: var(--radius);
      padding: 16px;
      display: flex;
      align-items: center;
      gap: 14px;
      box-shadow: var(--shadow);
      border: 1px solid transparent;
      transition: all 0.25s ease;
      position: relative;
    }

    .task-item.completed {
      opacity: 0.65;
      background: #f1f5f9;
    }

    .task-check {
      width: 28px;
      height: 28px;
      min-width: 28px;
      border-radius: 50%;
      border: 2px solid #cbd5e1;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      transition: all 0.2s;
    }

    .task-item.completed .task-check {
      background: var(--success);
      border-color: var(--success);
    }

    .task-check svg {
      stroke: white;
      stroke-width: 3;
      display: none;
      width: 16px;
      height: 16px;
    }

    .task-item.completed .task-check svg {
      display: block;
    }

    .task-content {
      flex: 1;
      min-width: 0;
    }

    .task-title {
      font-size: 16px;
      font-weight: 700;
      color: var(--text);
      word-break: break-word;
      transition: color 0.2s;
    }

    .task-item.completed .task-title {
      text-decoration: line-through;
      color: var(--text-muted);
    }

    .task-meta {
      display: flex;
      align-items: center;
      gap: 8px;
      margin-top: 6px;
      font-size: 12px;
      color: var(--text-muted);
      flex-wrap: wrap;
    }

    .badge {
      padding: 3px 8px;
      border-radius: 6px;
      font-weight: 600;
      font-size: 11px;
    }

    .badge-category {
      background: var(--primary-light);
      color: var(--primary);
    }

    .badge-priority-high { background: #fee2e2; color: var(--danger); }
    .badge-priority-med { background: #fef3c7; color: var(--warning); }
    .badge-priority-low { background: #e0f2fe; color: #0284c7; }

    .task-delete-btn {
      background: transparent;
      border: none;
      color: #94a3b8;
      cursor: pointer;
      padding: 8px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .task-delete-btn:active {
      background: #fee2e2;
      color: var(--danger);
    }

    /* حالة الفراغ */
    .empty-state {
      text-align: center;
      padding: 60px 20px;
      color: var(--text-muted);
    }

    .empty-state svg {
      width: 80px;
      height: 80px;
      margin-bottom: 16px;
      fill: #cbd5e1;
    }

    .empty-state h3 {
      font-size: 18px;
      margin-bottom: 6px;
      color: var(--text);
    }

    /* زر الإضافة العائم كبير للشاشات اللمسية */
    .fab-btn {
      position: fixed;
      bottom: 24px;
      left: 20px;
      right: 20px;
      background: linear-gradient(135deg, var(--primary), #6366f1);
      color: white;
      height: 56px;
      border: none;
      border-radius: 28px;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 10px;
      font-size: 17px;
      font-weight: 700;
      cursor: pointer;
      box-shadow: 0 10px 25px rgba(79, 70, 229, 0.4);
      z-index: 10;
    }

    .fab-btn:active {
      transform: scale(0.98);
    }

    /* نافذة إضافة مهمة (Modal) */
    .modal-overlay {
      position: fixed;
      inset: 0;
      background: rgba(15, 23, 42, 0.6);
      backdrop-filter: blur(4px);
      z-index: 100;
      display: flex;
      align-items: flex-end;
      opacity: 0;
      pointer-events: none;
      transition: opacity 0.3s;
    }

    .modal-overlay.active {
      opacity: 1;
      pointer-events: auto;
    }

    .modal-card {
      background: var(--surface);
      width: 100%;
      border-radius: 28px 28px 0 0;
      padding: 24px 20px 32px;
      transform: translateY(100%);
      transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1);
      max-height: 90vh;
      overflow-y: auto;
    }

    .modal-overlay.active .modal-card {
      transform: translateY(0);
    }

    .modal-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
    }

    .modal-title {
      font-size: 18px;
      font-weight: 800;
    }

    .close-btn {
      background: #f1f5f9;
      border: none;
      width: 36px;
      height: 36px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      font-size: 18px;
      color: var(--text-muted);
    }

    .form-group {
      margin-bottom: 16px;
    }

    .form-label {
      font-size: 13px;
      font-weight: 700;
      margin-bottom: 8px;
      display: block;
      color: var(--text-muted);
    }

    .form-input {
      width: 100%;
      padding: 14px 16px;
      border-radius: var(--radius-sm);
      border: 1.5px solid var(--border);
      font-size: 16px;
      outline: none;
      font-family: inherit;
      background: #f8fafc;
    }

    .form-input:focus {
      border-color: var(--primary);
      background: white;
    }

    .options-grid {
      display: flex;
      gap: 8px;
      overflow-x: auto;
      scrollbar-width: none;
    }
    .options-grid::-webkit-scrollbar { display: none; }

    .option-chip {
      padding: 10px 16px;
      border-radius: 12px;
      border: 1.5px solid var(--border);
      background: #f8fafc;
      font-size: 14px;
      cursor: pointer;
      white-space: nowrap;
      font-weight: 600;
    }

    .option-chip.selected {
      border-color: var(--primary);
      background: var(--primary-light);
      color: var(--primary);
    }

    .submit-btn {
      width: 100%;
      background: var(--primary);
      color: white;
      padding: 16px;
      border: none;
      border-radius: var(--radius-sm);
      font-size: 16px;
      font-weight: 800;
      margin-top: 10px;
      cursor: pointer;
    }

    .submit-btn:active {
      background: var(--primary-dark);
    }
  </style>
</head>
<body>

  <header>
    <div class="header-top">
      <div class="app-title">مهامي اليومية 📝</div>
      <div class="today-date" id="currentDate">اليوم</div>
    </div>
    
    <div class="progress-card">
      <div class="progress-info">
        <div class="progress-label" id="progressStatus">إنجاز اليوم: 0 من 0 مهام</div>
        <div class="progress-bar-bg">
          <div class="progress-bar-fill" id="progressBar"></div>
        </div>
      </div>
      <div class="progress-percent" id="progressPercent">0%</div>
    </div>
  </header>

  <div class="filters-wrap">
    <div class="filter-chip active" onclick="setFilter('all', this)">الكل</div>
    <div class="filter-chip" onclick="setFilter('pending', this)">قيد التنفيذ</div>
    <div class="filter-chip" onclick="setFilter('completed', this)">المكتملة</div>
    <div class="filter-chip" onclick="setFilter('personal', this)">شخصي</div>
    <div class="filter-chip" onclick="setFilter('work', this)">العمل</div>
    <div class="filter-chip" onclick="setFilter('health', this)">الصحة</div>
  </div>

  <main class="task-container" id="taskList"></main>

  <button class="fab-btn" onclick="openModal()">
    <svg width="22" height="22" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
      <line x1="12" y1="5" x2="12" y2="19"></line>
      <line x1="5" y1="12" x2="19" y2="12"></line>
    </svg>
    إضافة مهمة جديدة
  </button>

  <!-- Modal -->
  <div class="modal-overlay" id="taskModal">
    <div class="modal-card">
      <div class="modal-header">
        <div class="modal-title">إضافة مهمة جديدة</div>
        <button class="close-btn" onclick="closeModal()">✕</button>
      </div>

      <div class="form-group">
        <label class="form-label">عنوان المهمة</label>
        <input type="text" id="taskTitleInput" class="form-input" placeholder="مثال: مراجعة التقرير اليومي..." />
      </div>

      <div class="form-group">
        <label class="form-label">التصنيف</label>
        <div class="options-grid" id="categoryGroup">
          <div class="option-chip selected" data-val="personal" onclick="selectOption(this, 'categoryGroup')">شخصي</div>
          <div class="option-chip" data-val="work" onclick="selectOption(this, 'categoryGroup')">العمل</div>
          <div class="option-chip" data-val="health" onclick="selectOption(this, 'categoryGroup')">الصحة</div>
          <div class="option-chip" data-val="study" onclick="selectOption(this, 'categoryGroup')">دراسة</div>
        </div>
      </div>

      <div class="form-group">
        <label class="form-label">الأولوية</label>
        <div class="options-grid" id="priorityGroup">
          <div class="option-chip" data-val="high" onclick="selectOption(this, 'priorityGroup')">🔥 عالي</div>
          <div class="option-chip selected" data-val="med" onclick="selectOption(this, 'priorityGroup')">⚡ متوسط</div>
          <div class="option-chip" data-val="low" onclick="selectOption(this, 'priorityGroup')">☕ منخفض</div>
        </div>
      </div>

      <button class="submit-btn" onclick="saveTask()">حفظ المهمة</button>
    </div>
  </div>

  <script>
    // تهيئة التاريخ باللغة العربية
    const dateOptions = { weekday: 'long', month: 'short', day: 'numeric' };
    document.getElementById('currentDate').innerText = new Intl.DateTimeFormat('ar-EG', dateOptions).format(new Date());

    let tasks = JSON.parse(localStorage.getItem('my_daily_tasks') || '[]');
    let currentFilter = 'all';

    // نغمة خفيفة عند إنجاز المهمة (Web Audio API)
    function playBeep() {
      try {
        const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();
        osc.connect(gain);
        gain.connect(audioCtx.destination);
        osc.frequency.setValueAtTime(587.33, audioCtx.currentTime); // D5
        osc.frequency.exponentialRampToValueAtTime(880, audioCtx.currentTime + 0.15); // A5
        gain.gain.setValueAtTime(0.1, audioCtx.currentTime);
        gain.gain.linearRampToValueAtTime(0, audioCtx.currentTime + 0.15);
        osc.start();
        osc.stop(audioCtx.currentTime + 0.15);
      } catch (e) {}
    }

    function triggerVibrate() {
      if ('vibrate' in navigator) navigator.vibrate(40);
    }

    function saveToStorage() {
      localStorage.setItem('my_daily_tasks', JSON.stringify(tasks));
      render();
    }

    function openModal() {
      document.getElementById('taskModal').classList.add('active');
      document.getElementById('taskTitleInput').focus();
    }

    function closeModal() {
      document.getElementById('taskModal').classList.remove('active');
      document.getElementById('taskTitleInput').value = '';
    }

    function selectOption(el, groupId) {
      document.querySelectorAll(`#${groupId} .option-chip`).forEach(chip => chip.classList.remove('selected'));
      el.classList.add('selected');
    }

    function setFilter(filter, el) {
      currentFilter = filter;
      document.querySelectorAll('.filter-chip').forEach(c => c.classList.remove('active'));
      el.classList.add('active');
      render();
    }

    function saveTask() {
      const input = document.getElementById('taskTitleInput');
      const title = input.value.trim();
      if (!title) {
        input.focus();
        return;
      }

      const category = document.querySelector('#categoryGroup .selected').dataset.val;
      const priority = document.querySelector('#priorityGroup .selected').dataset.val;

      const newTask = {
        id: Date.now().toString(),
        title,
        category,
        priority,
        completed: false,
        time: new Date().toLocaleTimeString('ar-EG', { hour: '2-digit', minute: '2-digit' })
      };

      tasks.unshift(newTask);
      saveToStorage();
      closeModal();
      triggerVibrate();
    }

    function toggleTask(id) {
      tasks = tasks.map(t => {
        if (t.id === id) {
          const state = !t.completed;
          if (state) playBeep();
          return { ...t, completed: state };
        }
        return t;
      });
      triggerVibrate();
      saveToStorage();
    }

    function deleteTask(id) {
      tasks = tasks.filter(t => t.id !== id);
      triggerVibrate();
      saveToStorage();
    }

    function getCategoryName(key) {
      const map = { personal: 'شخصي', work: 'العمل', health: 'الصحة', study: 'دراسة' };
      return map[key] || 'أخرى';
    }

    function getPriorityDetails(p) {
      if (p === 'high') return { label: 'أولوية عالية', class: 'badge-priority-high' };
      if (p === 'low') return { label: 'أولوية منخفضة', class: 'badge-priority-low' };
      return { label: 'أولوية متوسطة', class: 'badge-priority-med' };
    }

    function render() {
      const container = document.getElementById('taskList');
      container.innerHTML = '';

      // تصفية
      let filtered = tasks;
      if (currentFilter === 'pending') filtered = tasks.filter(t => !t.completed);
      else if (currentFilter === 'completed') filtered = tasks.filter(t => t.completed);
      else if (['personal', 'work', 'health', 'study'].includes(currentFilter)) {
        filtered = tasks.filter(t => t.category === currentFilter);
      }

      // الإحصاءات وشريط التقدم
      const total = tasks.length;
      const completedCount = tasks.filter(t => t.completed).length;
      const percent = total === 0 ? 0 : Math.round((completedCount / total) * 100);

      document.getElementById('progressBar').style.width = percent + '%';
      document.getElementById('progressPercent').innerText = percent + '%';
      document.getElementById('progressStatus').innerText = `إنجاز اليوم: ${completedCount} من ${total} مهام`;

      if (filtered.length === 0) {
        container.innerHTML = `
          <div class="empty-state">
            <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-9 14l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>
            <h3>لا توجد مهام هنا</h3>
            <p>أنت جاهز لقضاء يوم رائع ومنجز!</p>
          </div>
        `;
        return;
      }

      filtered.forEach(task => {
        const priorityInfo = getPriorityDetails(task.priority);
        const item = document.createElement('div');
        item.className = `task-item ${task.completed ? 'completed' : ''}`;
        
        item.innerHTML = `
          <div class="task-check" onclick="toggleTask('${task.id}')">
            <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"></polyline></svg>
          </div>
          <div class="task-content" onclick="toggleTask('${task.id}')">
            <div class="task-title">${task.title}</div>
            <div class="task-meta">
              <span class="badge badge-category">${getCategoryName(task.category)}</span>
              <span class="badge ${priorityInfo.class}">${priorityInfo.label}</span>
              <span>${task.time}</span>
            </div>
          </div>
          <button class="task-delete-btn" onclick="deleteTask('${task.id}')" title="حذف">
            <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <polyline points="3 6 5 6 21 6"></polyline>
              <path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"></path>
              <path d="M10 11v6"></path>
              <path d="M14 11v6"></path>
            </svg>
          </button>
        `;
        container.appendChild(item);
      });
    }

    // إغلاق النافذة عند الضغط على الخلفية
    document.getElementById('taskModal').addEventListener('click', (e) => {
      if (e.target.id === 'taskModal') closeModal();
    });

    // أول تشغيل
    render();
  </script>
</body>
</html>