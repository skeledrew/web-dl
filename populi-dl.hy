; /usr/bin/hy

; populi-dl - Download student data from Populi


(import argparse requests ssl)
(import [requests.adapters [HTTPAdapter]])

(defclass TLSAdapter [HTTPAdapter]
          [[init-poolmanager
            (fn [self connections maxsize &optional [block False]]
                (setv (. self poolmanager) (PoolManager &optional [num-pools connections] [maxsize maxsize] [block block] [ssl_version (. ssl PROTOCOL_TLSv1)])))]])

(defclass Populi []
          
          [[session None]
           [student None]
           [pages None]])
(setv pop (Populi))  ; create single Populi instance

(defn create-session []
    (setv (. session pop) (.mount (.Session requests) "https://" (TLSAdapter))))

; - Authenticate
;(get-auth
;    (or (get-cookies browser) (get-user-creds *)))

;(get-profile-page 
;    (+ "https://dwci.populiweb.com/internal/people/person.php?personID=" (get-student-id (get-landing-page (get-session) "https://dwci.populiweb.com/internal/common/home.php"))))

;(get-course-material (get-each-course-instance (get-student-view (get-profile-page *))))