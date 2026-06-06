/// Arabic localization strings for the Xeemo Management System
/// This file provides centralized Arabic translations for the app
class AppStrings {
  // General
  static const String appName = 'نظام إدارة زيمو';
  static const String loading = 'جاري التحميل...';
  static const String error = 'حدث خطأ';
  static const String retry = 'إعادة المحاولة';
  static const String cancel = 'إلغاء';
  static const String confirm = 'تأكيد';
  static const String save = 'حفظ';
  static const String delete = 'حذف';
  static const String edit = 'تعديل';
  static const String search = 'بحث';
  static const String refresh = 'تحديث';
  static const String noData = 'لا توجد بيانات';

  // Authentication
  static const String login = 'تسجيل الدخول';
  static const String logout = 'تسجيل الخروج';
  static const String email = 'البريد الإلكتروني';
  static const String password = 'كلمة المرور';
  static const String confirmPassword = 'تأكيد كلمة المرور';
  static const String name = 'الاسم';
  static const String fullName = 'الاسم الكامل';

  // Validation
  static const String requiredField = 'هذا الحقل مطلوب';
  static const String invalidEmail = 'الرجاء إدخال بريد إلكتروني صالح';
  static const String passwordTooShort =
      'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل';
  static const String passwordNeedsUppercase =
      'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل';
  static const String passwordNeedsLowercase =
      'يجب أن تحتوي كلمة المرور على حرف صغير واحد على الأقل';
  static const String passwordNeedsNumber =
      'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل';
  static const String passwordMismatch = 'كلمتا المرور غير متطابقتين';
  static const String nameTooShort = 'يجب أن يتكون الاسم من 3 أحرف على الأقل';

  // Password strength
  static const String passwordStrength = 'قوة كلمة المرور';
  static const String passwordVeryWeak = 'ضعيفة جداً';
  static const String passwordWeak = 'ضعيفة';
  static const String passwordMedium = 'متوسطة';
  static const String passwordGood = 'جيدة';
  static const String passwordStrong = 'قوية';

  // Roles
  static const String worker = 'عامل';
  static const String manager = 'مدير';
  static const String superManager = 'مدير عام';

  // Account management
  static const String createWorker = 'إنشاء عامل جديد';
  static const String createManager = 'إنشاء مدير جديد';
  static const String workerList = 'قائمة المناديب';
  static const String managerList = 'قائمة المديرين';
  static const String addWorker = 'إضافة عامل';
  static const String addManager = 'إضافة مدير';
  static const String assignedArea = 'المنطقة المسؤول عنها';
  static const String createAccount = 'إنشاء الحساب';
  static const String accountCreatedSuccess = 'تم إنشاء الحساب بنجاح';
  static const String noWorkers = 'لا يوجد مناديب حتى الآن';
  static const String noManagers = 'لا يوجد مديرين حتى الآن';
  static const String addWorkerHint = 'اضغط على + لإضافة عامل جديد';
  static const String addManagerHint = 'اضغط على + لإضافة مدير جديد';

  // Analytics
  static const String analytics = 'التحليلات';
  static const String workerAnalytics = 'تحليلات المناديب';
  static const String performanceAnalytics = 'تحليلات الأداء';
  static const String totalSales = 'إجمالي المبيعات';
  static const String totalTickets = 'عدد التذاكر';
  static const String averageProductivity = 'متوسط الإنتاجية';
  static const String activityHours = 'ساعات النشاط';
  static const String dailySales = 'المبيعات اليومية';
  static const String dailyTickets = 'التذاكر اليومية';
  static const String productBreakdown = 'توزيع المنتجات';
  static const String charts = 'الرسوم البيانية';
  static const String trend = 'الاتجاه';
  static const String improving = 'أداء متحسن! 🎉';
  static const String needsImprovement = 'يحتاج لتحسين';
  static const String insufficientData = 'لا توجد بيانات كافية';

  // Date ranges
  static const String dateRange = 'نطاق التاريخ';
  static const String today = 'اليوم';
  static const String yesterday = 'أمس';
  static const String thisWeek = 'هذا الأسبوع';
  static const String lastWeek = 'الأسبوع الماضي';
  static const String thisMonth = 'هذا الشهر';
  static const String lastMonth = 'الشهر الماضي';
  static const String last7Days = 'آخر 7 أيام';
  static const String last30Days = 'آخر 30 يوم';
  static const String last90Days = 'آخر 90 يوم';
  static const String customRange = 'نطاق مخصص';
  static const String selectDateRange = 'اختر نطاق التاريخ';
  static const String dateValidationError =
      'تاريخ النهاية يجب أن يكون بعد أو يساوي تاريخ البداية';
  static const String futureDateError = 'لا يمكن تحديد تواريخ مستقبلية';

  // Tickets
  static const String tickets = 'التذاكر';
  static const String createTicket = 'إنشاء تذكرة';
  static const String ticketDetails = 'تفاصيل التذكرة';
  static const String editTicket = 'تعديل التذكرة';
  static const String ticketDashboard = 'لوحة التذاكر';

  // Products
  static const String products = 'المنتجات';
  static const String productManagement = 'إدارة المنتجات';
  static const String addProduct = 'إضافة منتج';

  // Currency
  static const String currency = 'ج.م';
  static const String perDay = 'س/يوم';

  // Errors
  static const String loadingError = 'حدث خطأ أثناء تحميل البيانات';
  static const String networkError = 'خطأ في الاتصال بالإنترنت';
  static const String unknownError = 'حدث خطأ غير معروف';
  static const String duplicateEmail = 'البريد الإلكتروني مسجل بالفعل';
  static const String invalidCredentials = 'بيانات الدخول غير صحيحة';
  static const String permissionDenied = 'ليس لديك صلاحية للقيام بهذا الإجراء';
  static const String loginRequired = 'يجب تسجيل الدخول أولاً';
  static const String superManagerOnly =
      'فقط المدير العام يمكنه القيام بهذا الإجراء';

  // Success messages
  static const String savedSuccessfully = 'تم الحفظ بنجاح';
  static const String deletedSuccessfully = 'تم الحذف بنجاح';
  static const String updatedSuccessfully = 'تم التحديث بنجاح';

  // Password requirements info
  static const String passwordRequirements = 'متطلبات كلمة المرور:';
  static const String passwordRequirementsDetails =
      '• 8 أحرف على الأقل\n• حرف كبير واحد على الأقل (A-Z)\n• حرف صغير واحد على الأقل (a-z)\n• رقم واحد على الأقل (0-9)';
}

/// Accessibility labels for screen readers
class AccessibilityLabels {
  static const String backButton = 'زر الرجوع';
  static const String refreshButton = 'زر التحديث';
  static const String addButton = 'زر الإضافة';
  static const String editButton = 'زر التعديل';
  static const String deleteButton = 'زر الحذف';
  static const String analyticsButton = 'عرض التحليلات';
  static const String searchField = 'حقل البحث';
  static const String datePickerButton = 'اختيار التاريخ';
  static const String menuButton = 'زر القائمة';
  static const String closeButton = 'زر الإغلاق';
  static const String passwordVisibilityToggle = 'إظهار/إخفاء كلمة المرور';
  static const String chartArea = 'منطقة الرسم البياني';
  static const String salesChart = 'رسم بياني للمبيعات';
  static const String ticketsChart = 'رسم بياني للتذاكر';
  static const String productChart = 'رسم بياني للمنتجات';
}
