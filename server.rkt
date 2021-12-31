#lang racketscript/base
(require racketscript/interop)

;; /**
;; * This is the main Node.js server script for your project
;; * Check out the two endpoints this back-end API provides in fastify.get and fastify.post below
;; */

(define process #js*.global.process)
(define console #js*.global.console)

(define PORT (if ($/defined? #js.process.env.PORT) #js.process.env.PORT 8080))

;; const path = require("path");
(define path ($/require "path"))

;; __dirname doesnt work in ES6, so use workaround
(define url ($/require "url"))
(define __dirname
  (#js.path.dirname (#js.url.fileURLToPath #js*.import.meta.url)))

;; // Require the fastify framework and instantiate it
;; const fastify = require("fastify")({
;;   // Set this to true for detailed logging:
;;   logger: false
;; });
(define _fastify ($/require "fastify"))
(define fastify (#js._fastify {$/obj [logger #f]}))

;; // ADD FAVORITES ARRAY VARIABLE FROM TODO HERE

;; // Setup our static files
;; fastify.register(require("fastify-static"), {
;;   root: path.join(__dirname, "public"),
;;   prefix: "/" // optional: default '/'
;; });
(define fastify-static ($/require "fastify-static"))
(#js.fastify.register
 fastify-static
 {$/obj [root (#js.path.join #js.__dirname #js"public")]
        [prefix #js"/"]}) ;; optional: default '/'

;; // fastify-formbody lets us parse incoming forms
;; fastify.register(require("fastify-formbody"));
(define fastify-formbody ($/require "fastify-formbody"))
(#js.fastify.register fastify-formbody)

;; // point-of-view is a templating manager for fastify
;; fastify.register(require("point-of-view"), {
;;   engine: {
;;     handlebars: require("handlebars")
;;   }
;; });
(define point-of-view ($/require "point-of-view"))
(define handlebars ($/require "handlebars"))
(#js.fastify.register
 point-of-view
 {$/obj [engine {$/obj [handlebars #js.handlebars]}]})

;; // Load and parse SEO data
;; const seo = require("./src/seo.json");
;; if (seo.url === "glitch-default") {
;;   seo.url = `https://${process.env.PROJECT_DOMAIN}.glitch.me`;
;; }
(define seo ($/require "./src/seo.json"))
(when ($/binop === #js.seo.url #js"glitch-default")
  (define seo-url ($/+ #js"https://" #js.process.env.PROJECT_DOMAIN #js".glitch.me"))
  ($/:= #js.seo.url seo-url))


;; /**
;; * Our home page route
;; *
;; * Returns src/pages/index.hbs with data built into it
;; */
;; fastify.get("/", function(request, reply) {
  
;;   // params is an object we'll pass to our handlebars template
;;   let params = { seo: seo };
  
;;   // If someone clicked the option for a random color it'll be passed in the querystring
;;   if (request.query.randomize) {
    
;;     // We need to load our color data file, pick one at random, and add it to the params
;;     const colors = require("./src/colors.json");
;;     const allColors = Object.keys(colors);
;;     let currentColor = allColors[(allColors.length * Math.random()) << 0];
    
;;     // Add the color properties to the params object
;;     params = {
;;       color: colors[currentColor],
;;       colorError: null,
;;       seo: seo
;;     };
;;   }
  
;;   // The Handlebars code will be able to access the parameter values and build them into the page
;;   reply.view("/src/pages/index.hbs", params);
;; });
(define colors ($/require "./src/colors.json"))

(define (handle-get request reply)
  (define params 
    (if ($/defined? #js.request.query.randomize)
        (let* ([allColors (#js*.Object.keys colors)]
               [randColor (truncate (* #js.allColors.length (#js*.Math.random)))]
               [currentColor ($ allColors randColor)])
          {$/obj [color ($ colors currentColor)]
                 [colorError $/null]
                 [seo seo]})
        {$/obj [seo seo]}))
  (#js.reply.view #js"/src/pages/index.hbs" params))      

(#js.fastify.get #js"/" handle-get)
 

;; /**
;; * Our POST route to handle and react to form submissions 
;; *
;; * Accepts body data indicating the user choice
;; */
;; fastify.post("/", function(request, reply) {
  
;;   // Build the params object to pass to the template
;;   let params = { seo: seo };
  
;;   // If the user submitted a color through the form it'll be passed here in the request body
;;   let color = request.body.color;
  
;;   // If it's not empty, let's try to find the color
;;   if (color) {
;;     // ADD CODE FROM TODO HERE TO SAVE SUBMITTED FAVORITES
    
;;     // Load our color data file
;;     const colors = require("./src/colors.json");
    
;;     // Take our form submission, remove whitespace, and convert to lowercase
;;     color = color.toLowerCase().replace(/\s/g, "");
    
;;     // Now we see if that color is a key in our colors object
;;     if (colors[color]) {
      
;;       // Found one!
;;       params = {
;;         color: colors[color],
;;         colorError: null,
;;         seo: seo
;;       };
;;     } else {
      
;;       // No luck! Return the user value as the error property
;;       params = {
;;         colorError: request.body.color,
;;         seo: seo
;;       };
;;     }
;;   }
  
;;   // The Handlebars template will use the parameter values to update the page with the chosen color
;;   reply.view("/src/pages/index.hbs", params);
;; });
(define (handle-post request reply)
  (define req-color #js.request.body.color)
  (define params
    (if ($/defined? req-color)
        (let ([color ($> (#js.req-color.toLowerCase) (trim))])
          (if ($/defined? ($ colors color))
              ;; Found one!
              {$/obj [color ($ colors color)]
                     [colorError $/null]
                     [seo seo]}
              {$/obj [colorError req-color]
                     [seo seo]}))
        {$/obj [seo seo]}))
  (#js.reply.view #js"/src/pages/index.hbs" params))

(#js.fastify.post #js"/" handle-post)

;; // Run the server and report out to the logs
;; fastify.listen(process.env.PORT, '0.0.0.0', function(err, address) {
;;   if (err) {
;;     fastify.log.error(err);
;;     process.exit(1);
;;   }
;;   console.log(`Your app is listening on ${address}`);
;;   fastify.log.info(`server listening on ${address}`);
;; });
(define (handle-listen err address)
  (unless ($/null? err)
    (#js.fastify.log.error err)
    (#js.process.exit 1))
  (#js.console.log ($/+ #js"Your app is listening on " address))
  (#js.fastify.log.info ($/+ #js"server listening on " address)))

(#js.fastify.listen PORT #js"0.0.0.0" handle-listen)
