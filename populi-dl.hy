; /usr/bin/hy

; populi-dl - Download student data from Populi
; Created: 15-11-14


(import argparse requests ssl)
(import [requests.adapters [HTTPAdapter]])
(import [urllib3 [PoolManager]])
(import [.cookies [AuthenticationFailed get_cookies make_cookie_values TLSAdapter]])

;(defclass TLSAdapter [HTTPAdapter]
;          "A customized HTTP Adapter which uses TLS v1.2 for encrypted connections. (Ripped from coursera-dl/cookies.py)"
          
;          [[init-poolmanager
;            (fn [self connections maxsize &optional [block False]]
;                (setv (. self poolmanager) (PoolManager :num-pools connections :maxsize maxsize :block block :ssl_version (. ssl PROTOCOL_TLSv1))))]])

(defclass Populi []
          "Holds information accessed on Populi website."
          
          [[session None]
           [student None]
           [pages None]])

(setv pop (Populi))  ; create single Populi instance

;defn get-cookies [&optional [cookies-file None] [username None] [password None]]
;      (create-session)
;      (if cookies-file 
;      )

(defn get-session []
    (setv (. pop session) (.mount (.Session requests) "https://" (TLSAdapter))))

(defn get-page [url]
      (setv r (.get (. pop session) url))
      (try
          (.raise_for_status r)
          (catch [e requests.exceptions.HTTPError] (do (.error logging "Error %s getting page %s" e url) (raise)))
          (else (. r text))))

; - Authenticate
;(get-auth
;    (or (get-cookies browser) (get-user-creds *)))

;(get-profile-page 
;    (+ "https://dwci.populiweb.com/internal/people/person.php?personID=" (get-student-id (get-landing-page (get-session) "https://dwci.populiweb.com/internal/common/home.php"))))

;(get-course-material (get-each-course-instance (get-student-view (get-profile-page *))))