;; Material Registration Contract
;; Records details of specialized teaching resources

(define-data-var next-material-id uint u0)

(define-map materials
  { material-id: uint }
  {
    title: (string-utf8 100),
    creator: principal,
    subject: (string-utf8 50),
    grade-level: (string-utf8 20),
    creation-date: uint,
    description: (string-utf8 500),
    uri: (string-utf8 200)
  }
)

(define-public (register-material
    (title (string-utf8 100))
    (subject (string-utf8 50))
    (grade-level (string-utf8 20))
    (description (string-utf8 500))
    (uri (string-utf8 200)))
  (let ((material-id (var-get next-material-id)))
    (map-set materials
      { material-id: material-id }
      {
        title: title,
        creator: tx-sender,
        subject: subject,
        grade-level: grade-level,
        creation-date: block-height,
        description: description,
        uri: uri
      }
    )
    (var-set next-material-id (+ material-id u1))
    (ok material-id)
  )
)

(define-read-only (get-material (material-id uint))
  (map-get? materials { material-id: material-id })
)

(define-read-only (get-material-count)
  (var-get next-material-id)
)
