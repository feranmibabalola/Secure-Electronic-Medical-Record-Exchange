;; Audit Trail Contract
;; Tracks all access to sensitive health information

(define-data-var admin principal tx-sender)

;; Map of audit events
(define-map audit-events
  { event-id: uint }
  {
    record-id: (string-utf8 64),
    accessed-by: (string-utf8 64), ;; provider-id
    action-type: (string-utf8 32), ;; "read", "write", "delete", etc.
    timestamp: uint,
    success: bool,
    details: (string-utf8 256)
  }
)

;; Counter for event IDs
(define-data-var event-counter uint u0)

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin))
)

;; Log an audit event
(define-public (log-event
  (record-id (string-utf8 64))
  (provider-id (string-utf8 64))
  (action-type (string-utf8 32))
  (success bool)
  (details (string-utf8 256))
)
  (let (
    (event-id (var-get event-counter))
    ;; In a real implementation, we would verify the caller is authorized
    ;; For simplicity, we're allowing any contract call
  )
    (var-set event-counter (+ event-id u1))
    (ok (map-set audit-events
      { event-id: event-id }
      {
        record-id: record-id,
        accessed-by: provider-id,
        action-type: action-type,
        timestamp: block-height,
        success: success,
        details: details
      }
    ))
  )
)

;; Get an audit event
(define-read-only (get-event (event-id uint))
  (map-get? audit-events { event-id: event-id })
)

;; Get the total number of audit events
(define-read-only (get-event-count)
  (var-get event-counter)
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) (err u1))
    (ok (var-set admin new-admin))
  )
)

