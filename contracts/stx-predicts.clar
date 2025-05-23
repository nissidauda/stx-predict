(define-data-var admin principal tx-sender) ;; Contract administrator

;; Data Variables
(define-data-var total-pool uint u0) ;; Total STX in the market
(define-data-var fee-rate uint u2) ;; 2% fee rate for admin

;; Stores market details
(define-map markets 
  { market-id: uint } 
  { creator: principal, resolution: (optional principal), status: bool, total-bets: uint, outcome: (optional uint) }) 

;; User bets on markets
(define-map bets 
  { market-id: uint, better: principal } 
  { amount: uint }) 

;; Public Functions
(define-public (create-market (market-id uint))
  (begin
    (asserts! (is-none (map-get? markets { market-id: market-id })) (err u100)) ;; Ensure market doesn't exist
    (map-set markets { market-id: market-id } 
      { creator: tx-sender, resolution: none, status: false, total-bets: u0, outcome: none })
    (ok true)
  )
)

(define-public (place-bet (market-id uint) (amount uint))
  (begin
    (asserts! (> amount u0) (err u101)) ;; Must bet more than 0
    (match (map-get? markets { market-id: market-id })
      some-market (begin
        (asserts! (not (get status some-market)) (err u102)) ;; Ensure market is active
        (let ((current-bet (get amount (default-to { amount: u0 } (map-get? bets { market-id: market-id, better: tx-sender })))))
          (match (stx-transfer? amount tx-sender (as-contract tx-sender))
            success-tx (begin
              (map-set bets { market-id: market-id, better: tx-sender } { amount: (+ current-bet amount) })
              (map-set markets { market-id: market-id } 
                { creator: (get creator some-market), 
                  resolution: (get resolution some-market), 
                  status: (get status some-market), 
                  total-bets: (+ (get total-bets some-market) amount), 
                  outcome: (get outcome some-market) })
              (var-set total-pool (+ (var-get total-pool) amount))
              (ok true))
            error (err u103))))
      (err u104)) ;; Market does not exist
  )
)

(define-public (resolve-market (market-id uint) (winning-outcome uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u105)) ;; Only admin can resolve
    (match (map-get? markets { market-id: market-id })
      some-market (begin
        (asserts! (not (get status some-market)) (err u106)) ;; Ensure market is active
        (map-set markets { market-id: market-id } 
          { creator: (get creator some-market), 
            resolution: (some tx-sender), 
            status: true, 
            total-bets: (get total-bets some-market), 
            outcome: (some winning-outcome) })
        (ok true))
      (err u107)) ;; Market does not exist
  )
)

;; ...existing code...

(define-public (claim-winnings (market-id uint))
  (let ((market (unwrap! (map-get? markets { market-id: market-id }) (err u112)))
        (bet (unwrap! (map-get? bets { market-id: market-id, better: tx-sender }) (err u111)))
        (outcome (unwrap! (get outcome market) (err u113))))
    
    (asserts! (get status market) (err u108)) ;; Ensure market is resolved
    (asserts! (is-eq outcome market-id) (err u109)) ;; Ensure user bet on winning outcome
    
    (let ((fee (/ (* (get amount bet) (var-get fee-rate)) u100))
          (payout (- (get amount bet) fee)))
      
      (match (stx-transfer? payout (as-contract tx-sender) tx-sender)
        success (begin
          (map-delete bets { market-id: market-id, better: tx-sender })
          (ok true))
        error (err u110)))))

;; ...existing code...