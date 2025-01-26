;; Aid Management Contract

(define-data-var next-request-id uint u0)
(define-data-var next-pledge-id uint u0)

(define-map aid-requests
  { request-id: uint }
  {
    requester: principal,
    disaster-type: (string-ascii 50),
    location: (string-ascii 100),
    resources-needed: (list 10 (string-ascii 50)),
    status: (string-ascii 20),
    created-at: uint
  }
)

(define-map resource-pledges
  { pledge-id: uint }
  {
    pledger: principal,
    request-id: uint,
    resource-type: (string-ascii 50),
    quantity: uint,
    status: (string-ascii 20),
    created-at: uint
  }
)

(define-public (create-aid-request
    (disaster-type (string-ascii 50))
    (location (string-ascii 100))
    (resources-needed (list 10 (string-ascii 50))))
  (let
    ((new-id (var-get next-request-id))
     (requester tx-sender))
    (map-set aid-requests
      { request-id: new-id }
      {
        requester: requester,
        disaster-type: disaster-type,
        location: location,
        resources-needed: resources-needed,
        status: "open",
        created-at: block-height
      }
    )
    (var-set next-request-id (+ new-id u1))
    (ok new-id)
  )
)

(define-public (pledge-resources
    (request-id uint)
    (resource-type (string-ascii 50))
    (quantity uint))
  (let
    ((new-id (var-get next-pledge-id))
     (pledger tx-sender))
    (asserts! (is-some (map-get? aid-requests { request-id: request-id })) (err u404))
    (map-set resource-pledges
      { pledge-id: new-id }
      {
        pledger: pledger,
        request-id: request-id,
        resource-type: resource-type,
        quantity: quantity,
        status: "pledged",
        created-at: block-height
      }
    )
    (var-set next-pledge-id (+ new-id u1))
    (ok new-id)
  )
)

(define-read-only (get-aid-request (request-id uint))
  (map-get? aid-requests { request-id: request-id })
)

(define-read-only (get-resource-pledge (pledge-id uint))
  (map-get? resource-pledges { pledge-id: pledge-id })
)

(define-public (update-request-status (request-id uint) (new-status (string-ascii 20)))
  (let ((requester tx-sender))
    (match (map-get? aid-requests { request-id: request-id })
      request (begin
        (asserts! (is-eq requester (get requester request)) (err u403))
        (map-set aid-requests
          { request-id: request-id }
          (merge request { status: new-status })
        )
        (ok true)
      )
      (err u404)
    )
  )
)

(define-public (update-pledge-status (pledge-id uint) (new-status (string-ascii 20)))
  (let ((pledger tx-sender))
    (match (map-get? resource-pledges { pledge-id: pledge-id })
      pledge (begin
        (asserts! (is-eq pledger (get pledger pledge)) (err u403))
        (map-set resource-pledges
          { pledge-id: pledge-id }
          (merge pledge { status: new-status })
        )
        (ok true)
      )
      (err u404)
    )
  )
)
