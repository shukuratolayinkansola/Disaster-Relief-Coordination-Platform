;; Volunteer Management Contract

(define-data-var next-volunteer-id uint u0)

(define-map volunteers
  { volunteer-id: uint }
  {
    name: (string-ascii 50),
    skills: (list 5 (string-ascii 20)),
    availability: (string-ascii 50),
    location: (string-ascii 100),
    status: (string-ascii 20),
    principal: principal
  }
)

(define-public (register-volunteer
    (name (string-ascii 50))
    (skills (list 5 (string-ascii 20)))
    (availability (string-ascii 50))
    (location (string-ascii 100)))
  (let
    ((new-id (var-get next-volunteer-id))
     (volunteer tx-sender))
    (map-set volunteers
      { volunteer-id: new-id }
      {
        name: name,
        skills: skills,
        availability: availability,
        location: location,
        status: "available",
        principal: volunteer
      }
    )
    (var-set next-volunteer-id (+ new-id u1))
    (ok new-id)
  )
)

(define-read-only (get-volunteer (volunteer-id uint))
  (map-get? volunteers { volunteer-id: volunteer-id })
)

(define-public (update-volunteer-status (volunteer-id uint) (new-status (string-ascii 20)))
  (let ((volunteer tx-sender))
    (match (map-get? volunteers { volunteer-id: volunteer-id })
      v (begin
        (asserts! (is-eq volunteer (get principal v)) (err u403))
        (map-set volunteers
          { volunteer-id: volunteer-id }
          (merge v { status: new-status })
        )
        (ok true)
      )
      (err u404)
    )
  )
)

