class OrderStatus {
  static const requestSent = 'request_sent';
  static const inContact = 'in_contact';
  static const quotationApproved = 'quotation_approved';
  static const orderConfirmed = 'order_confirmed';
  static const depositReceived = 'deposit_received';
  static const preparationsBegin = 'preparations_begin';
  static const completed = 'completed';
  static const declined = 'declined';
  static const cancelled = 'cancelled';

  // The happy-path stepper stages, in order (matches the design screenshot).
  static const steps = [
    requestSent,
    inContact,
    quotationApproved,
    orderConfirmed,
    depositReceived,
    preparationsBegin,
  ];

  // Every value the database actually accepts (matches the check constraint).
  // Used for screens, like Update Progress, where staff may need to set a
  // terminal status directly rather than only stepping through the stages.
  static const all = [
    requestSent,
    inContact,
    quotationApproved,
    orderConfirmed,
    depositReceived,
    preparationsBegin,
    completed,
    declined,
    cancelled,
  ];

  static const labels = {
    requestSent: 'Request sent',
    inContact: 'In contact',
    quotationApproved: 'Quotation approved',
    orderConfirmed: 'Order confirmed',
    depositReceived: 'Deposit received',
    preparationsBegin: 'Preparations begin',
    completed: 'Completed',
    declined: 'Declined',
    cancelled: 'Cancelled',
  };

  static String label(String status) => labels[status] ?? status;

  static int stepIndex(String status) => steps.indexOf(status);
}