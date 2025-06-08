;; Energy Optimization Contract
;; This contract optimizes home energy usage

(define-data-var admin principal tx-sender)

;; Data structure for energy consumption records
(define-map energy-consumption
  { device-id: (string-ascii 64), timestamp: uint }
  {
    owner: principal,
    energy-used: uint,
    duration: uint,
    cost: uint
  }
)

;; Map to track device energy efficiency
(define-map device-efficiency
  { device-id: (string-ascii 64) }
  {
    owner: principal,
    efficiency-rating: uint,
    last-optimized: uint,
    energy-saving-mode: bool,
    daily-limit: uint,
    current-usage: uint
  }
)

;; Public function to record energy consumption
(define-public (record-energy-consumption
                (device-id (string-ascii 64))
                (energy-used uint)
                (duration uint)
                (cost uint))
  (let ((caller tx-sender)
        (timestamp block-height))
    (map-insert energy-consumption
                { device-id: device-id, timestamp: timestamp }
                {
                  owner: caller,
                  energy-used: energy-used,
                  duration: duration,
                  cost: cost
                })
    (ok true)))

;; Public function to set device efficiency parameters
(define-public (set-device-efficiency
                (device-id (string-ascii 64))
                (efficiency-rating uint)
                (energy-saving-mode bool)
                (daily-limit uint))
  (let ((caller tx-sender))
    (match (map-get? device-efficiency { device-id: device-id })
      efficiency (if (is-eq caller (get owner efficiency))
                    (begin
                      (map-set device-efficiency
                               { device-id: device-id }
                               (merge efficiency {
                                 efficiency-rating: efficiency-rating,
                                 energy-saving-mode: energy-saving-mode,
                                 daily-limit: daily-limit,
                                 last-optimized: block-height
                               }))
                      (ok true))
                    (err u1))
      (begin
        (map-insert device-efficiency
                    { device-id: device-id }
                    {
                      owner: caller,
                      efficiency-rating: efficiency-rating,
                      last-optimized: block-height,
                      energy-saving-mode: energy-saving-mode,
                      daily-limit: daily-limit,
                      current-usage: u0
                    })
        (ok true)))))

;; Public function to update current energy usage
(define-public (update-energy-usage
                (device-id (string-ascii 64))
                (usage-amount uint))
  (let ((caller tx-sender))
    (match (map-get? device-efficiency { device-id: device-id })
      efficiency (if (is-eq caller (get owner efficiency))
                    (begin
                      (map-set device-efficiency
                               { device-id: device-id }
                               (merge efficiency {
                                 current-usage: (+ (get current-usage efficiency) usage-amount)
                               }))
                      (ok true))
                    (err u2))
      (err u3))))

;; Public function to reset daily usage counter
(define-public (reset-daily-usage (device-id (string-ascii 64)))
  (let ((caller tx-sender))
    (match (map-get? device-efficiency { device-id: device-id })
      efficiency (if (is-eq caller (get owner efficiency))
                    (begin
                      (map-set device-efficiency
                               { device-id: device-id }
                               (merge efficiency { current-usage: u0 }))
                      (ok true))
                    (err u4))
      (err u5))))

;; Public function to check if device is over daily limit
(define-read-only (is-over-limit (device-id (string-ascii 64)))
  (match (map-get? device-efficiency { device-id: device-id })
    efficiency (ok (> (get current-usage efficiency) (get daily-limit efficiency)))
    (err u6)))

;; Public function to get device efficiency details
(define-read-only (get-device-efficiency (device-id (string-ascii 64)))
  (map-get? device-efficiency { device-id: device-id }))

;; Public function to optimize energy usage based on patterns
(define-public (optimize-energy-usage (device-id (string-ascii 64)))
  (let ((caller tx-sender))
    (match (map-get? device-efficiency { device-id: device-id })
      efficiency (if (is-eq caller (get owner efficiency))
                    (begin
                      (map-set device-efficiency
                               { device-id: device-id }
                               (merge efficiency {
                                 energy-saving-mode: true,
                                 last-optimized: block-height
                               }))
                      (ok true))
                    (err u7))
      (err u8))))
