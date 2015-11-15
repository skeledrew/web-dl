; /usr/bin/hy

; populi-dl - Download student data from Populi
; Created: 15-11-14


(import argparse requests ssl)
(import [requests.adapters [HTTPAdapter]])
(import [.cookies [AuthenticationFailed get_cookies make_cookie_values TLSAdapter]])

(defclass Populi []
          "Holds information accessed on Populi website."
          
          [[topdom ".populiweb.com"]
           [session None]
           [student None]
           [pages None]])

(setv pop (Populi))  ; create single Populi instance

(defn get-session []
    (setv s (.Session requests))
    (.mount s "https://" (TLSAdapter))
    (setv (. pop session) s))  ; replace 1-liner for now
    ;(setv (. pop session) (.mount (.Session requests) "https://" (TLSAdapter))))  ; disabled till check

(defn get-page [url]
      (setv r (.get (. pop session) url))
      (try
          (.raise_for_status r)
          (catch [e requests.exceptions.HTTPError] (do (.error logging "Error %s getting page %s" e url) (raise)))
          (else (. r text))))


; - Authenticate
(get-session)
;(print (. (.get (. pop session) "https://dwci.populiweb.com") text))  ; test object
(get-cookies (. pop session) (. pop topdom) :cookies-file "./cookies.txt" :username None :password None)

(setv (. pop session cookie_values) (make_cookie_values (. pop session cookies) (. pop topdom)))
(print (. pop session cookie_values))  ; test the whole thing now...

;(get-profile-page 
;    (+ "https://dwci.populiweb.com/internal/people/person.php?personID=" (get-student-id (get-landing-page (get-session) "https://dwci.populiweb.com/internal/common/home.php"))))

;(get-course-material (get-each-course-instance (get-student-view (get-profile-page *))))