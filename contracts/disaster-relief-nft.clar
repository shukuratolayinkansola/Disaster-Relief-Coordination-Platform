;; Disaster Relief NFT Contract

(define-non-fungible-token disaster-relief-nft uint)

(define-data-var last-token-id uint u0)

(define-map token-uris { token-id: uint } { uri: (string-utf8 256) })

(define-public (mint (recipient principal) (token-uri (string-utf8 256)))
  (let
    ((token-id (+ (var-get last-token-id) u1)))
    (try! (nft-mint? disaster-relief-nft token-id recipient))
    (map-set token-uris { token-id: token-id } { uri: token-uri })
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err u403))
    (nft-transfer? disaster-relief-nft token-id sender recipient)
  )
)

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (token-id uint))
  (ok (get uri (map-get? token-uris { token-id: token-id })))
)

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? disaster-relief-nft token-id))
)

