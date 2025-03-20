;; Adaptation Sharing Contract
;; Records modifications for different learning needs

(define-data-var next-adaptation-id uint u0)

(define-map adaptations
  { adaptation-id: uint }
  {
    original-material-id: uint,
    creator: principal,
    title: (string-utf8 100),
    description: (string-utf8 500),
    adaptation-type: (string-utf8 50), ;; e.g., "visual", "auditory", "kinesthetic"
    target-needs: (string-utf8 100),   ;; e.g., "dyslexia", "ADHD", "visual impairment"
    uri: (string-utf8 200),
    creation-date: uint
  }
)

(define-map material-adaptations
  { material-id: uint }
  { adaptation-ids: (list 20 uint) }
)

(define-public (share-adaptation
    (original-material-id uint)
    (title (string-utf8 100))
    (description (string-utf8 500))
    (adaptation-type (string-utf8 50))
    (target-needs (string-utf8 100))
    (uri (string-utf8 200)))
  (let (
    (adaptation-id (var-get next-adaptation-id))
    (current-adaptations (default-to { adaptation-ids: (list) }
                         (map-get? material-adaptations { material-id: original-material-id })))
  )
    ;; Store the adaptation
    (map-set adaptations
      { adaptation-id: adaptation-id }
      {
        original-material-id: original-material-id,
        creator: tx-sender,
        title: title,
        description: description,
        adaptation-type: adaptation-type,
        target-needs: target-needs,
        uri: uri,
        creation-date: block-height
      }
    )

    ;; Update the list of adaptations for the original material
    (map-set material-adaptations
      { material-id: original-material-id }
      { adaptation-ids: (unwrap! (as-max-len?
                                 (append (get adaptation-ids current-adaptations) adaptation-id)
                                 u20)
                                 (err u1)) }
    )

    ;; Increment the adaptation ID counter
    (var-set next-adaptation-id (+ adaptation-id u1))
    (ok adaptation-id)
  )
)

(define-read-only (get-adaptation (adaptation-id uint))
  (map-get? adaptations { adaptation-id: adaptation-id })
)

(define-read-only (get-material-adaptations (material-id uint))
  (map-get? material-adaptations { material-id: material-id })
)
