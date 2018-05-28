exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: "js/app.js"
    },
    stylesheets: {
      joinTo: "css/app.css",
      order: {
        after: ["css/app.scss"] // concat app.css last
      }
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/assets/static". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(web\/static\/assets)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: ["web/static", "css", "js", "vendor", "scss", "fonts"],
    // Where to compile files to
    public: "priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/web\/static\/vendor/]
    },
    sass: {
      mode: 'native',
      options: {
        includePaths: ["node_modules/adminator/src/assets/styles", "node_modules/bootstrap-sass/assets/stylesheets", "node_modules/font-awesome/scss"], // Tell sass-brunch where to look for files to @import
        precision: 8 // Minimum precision required by bootstrap-sass
      }
    },
    copycat: {
      "static": ["node_modules/adminator/src/assets/static"],
      "fonts/bootstrap": ["node_modules/bootstrap-sass/assets/fonts/bootstrap"],
      "fonts" : ["web/static/fonts", "node_modules/font-awesome/fonts"],
      verbose : false, //shows each file that is copied to the destination directory
      onlyChanged: true //only copy a file if it's modified time has changed (only effective when using brunch watch)
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": ["web/static/js/app"]
    }
  },
  npm: {
    enabled: true,
    globals: { // Bootstrap's JavaScript requires both '$' and 'jQuery' in global scope
      $: 'jquery',
      jQuery: 'jquery',
      bootstrap: 'bootstrap-sass'
    }
  }
};
// "node_modules/gentelella/documentation/css", "node_modules/gentelella/src/scss",