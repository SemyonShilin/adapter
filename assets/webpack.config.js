const path = require('path');

module.exports = {
  entry: "./js/app.js",
  output: {
    path: path.resolve(__dirname, "../priv/static/js"),
    filename: "app.js"
  },
  devServer: {
    inline: false,
    contentBase: "../priv/static/js",
  },
  module: {
    rules: [{
      test: /\.js$/,
      loader: "babel-loader",
      query: {
        presets: ["es2015"]
      }
    }]
  },
  stats: {
    colors: true
  },
  mode: "development",
  watch: true
};