; /usr/bin/hy

; populi-dl - Download student data from Populi
; Created: 15-11-14


(import argparse requests ssl re)
(import [requests.adapters [HTTPAdapter]])
(import [.cookies [AuthenticationFailed get_cookies make_cookie_values TLSAdapter]])
(import [bs4 [BeautifulSoup]])

(defclass Populi []
          "Holds information accessed on Populi website."
          
          [[topdom ".populiweb.com"]
           [subdom "dwci"]
           [proto "https://"]
           [base-path None]
           [session None]
           [student None]
           [pages None]])

(setv pop (Populi))  ; create single Populi instance

(defn get-session []
    "Setup a new session for cookie support"
    (setv s (.session requests))
    (setv (. pop session) s))  ; replace 1-liner for now
    ;(setv (. pop session) (.mount (.Session requests) "https://" (TLSAdapter))))  ; disabled till check

(defn login [url username password]
      "Login to Populi site
      15-11-21"
      (setv data {"username" username "password" password})
      (.post (. pop session) url :data data))

(defn get-page [url]
      (setv r (.get (. pop session) url))
      (try
          (.raise_for_status r)
          (catch [e requests.exceptions.HTTPError] (do (.error logging "Error %s getting page %s" e url) (raise)))
          (else (. r text)))
      (BeautifulSoup (. r text) 'html5lib))

(defn parse-args []
      "Process username and password from command line
      15-11-21"
      (setv parser (.ArgumentParser argparse :description "Download student records from Populi CMS"))
      (.add-argument parser :dest 'username :action 'store :default None :help "Populi username")
      (.add-argument parser 'password :action 'store :default None :help "Populi password")
      (.parse-args parser)
      )

(defn get-course-instances [page]
      "Process courses summary page
      15-11-21"
      (setv links (.find-all page :href (.compile re "/courseofferings/")))
      (for [link links] (do (print "Grabbing" (. link string) "resources...") 
                            (get-course-material (get link "href") (-> link (get "href") (.split "/") (get 3)))))
      (get-resources page)
      )

(defn get-course-material [url filter]
      "Spider html pages, using filter to stick to related pages
      15-11-22"
      (setv page (get-page (if (= (get url 0) "/") (+ (. pop proto) (. pop subdom) (. pop topdom) url) url)))
      (save (.prettify page) (+ (or (. pop base-path) "~/Documents") "/populi-dl/courses" url))
      (for [link (.find-all page :href (.compile re filter))] (get-course-material link filter))
      )

(defn save [text file]
      "Save text to a file, overwrite if it exists
      15-11-22"
      (with [[f (open file "w")]] (.write f text))
      )

(defn get-resources [page]
      "Get non-html resources
      15-11-22"
      
      )

;(defn get-material [links filter]
;      "Recursively get only html resources containing the filter
;      15-11-22"
;      (for [link links]
;           (do (setv filter (or filter (-> link (get "href") (.split "/") (get 3))))
;               (get-material (.find-all (. pop student-page) :href (.compile re "filter") filter)
;               )
;           )
;      )
      
(get-session)
;(print (. (.get (. pop session) "https://dwci.populiweb.com") text))  ; tested ok 15-11-15 1745
;(get-cookies (. pop session) (. pop topdom) :cookies-file "./cookies.txt" :username None :password None)  ; TODO: Get path to original cookie file
;(setv (. pop session cookie_values) (make_cookie_values (. pop session cookies) (. pop topdom)))
;(setv landing-page (login "https://dwci.populiweb.com/internal/index.php"
;(print (get-page "https://dwci.populiweb.com/internal/common/home.php"))
;(print (. pop session cookie_values))  ; test cookie read

;(get-profile-page 
;    (+ "https://dwci.populiweb.com/internal/people/person.php?personID=" (get-student-id (get-landing-page (get-session) "https://dwci.populiweb.com/internal/common/home.php"))))

;(get-course-material (get-course-instances (get-student-view (get-profile-page *))))
(defn main []
      (setv args (parse-args))
      (print "Username is " (. args username) "\n")
      (login "https://dwci.populiweb.com/internal/index.php" (. args username) (. args password))
      (setv landing-page (get-page "https://dwci.populiweb.com/internal/common/home.php"))
      (print (+ "Welcome " (. landing-page a span next-sibling string) "!"))
      (setv (. pop student-id) (get (.split (get (get (.find-all landing-page "a" :string "My Profile") 0) "href") "=") 1))
      (setv bb-page (get-page (+ "https://dwci.populiweb.com/internal/people/person.php?personID=" (. pop student-id) "&view=BULLETIN_BOARD")))
      (setv (. pop student-page) (get-page (+ "https://dwci.populiweb.com/internal/people/person.php?personID=" (. pop student-id) "&view=STUDENT")))
      (setv courses-dict (get-course-instances (. pop student-page)))
      (print courses-dict)
      )

(main)
(print "\n\nDone!!!")