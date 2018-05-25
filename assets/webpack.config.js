const path = require('path');
const ExtractTextPlugin = require("extract-text-webpack-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin")

module.exports = function(env) {
  const production = false;
  return {
    devServer: {
      headers: {
        'Access-Control-Allow-Origin': '*',
      },
    },
    devtool: production ? 'source-maps' : 'eval',
    entry: ["./css/app.scss", "./js/app.js"],
    output: {
      path: path.resolve(__dirname, "../priv/static"),
      filename: "js/app.js"
    },
    module: {
      rules: [
        {
          test: /\.jsx?$/,
          exclude: /node_modules/,
          loader: "babel-loader",
          query:
            {
              presets:['es2015', 'react']
            }
        },
        {
          test: /\.scss$/,
          use: ExtractTextPlugin.extract({
            use: [{
              loader: "css-loader",
              options: {
                minimize: true,
                sourceMap: env === 'production',
              },
            }, {
              loader: "sass-loader",
              options: {
                includePaths: [path.resolve('node_modules')],
              }
            }],
            fallback: "style-loader"
          })
        }, {
          test: /\.(ttf|otf|eot|svg|woff(2)?)(\?[a-z0-9]+)?$/,
          // put fonts in assets/static/fonts/
          loader: 'file-loader?name=/fonts/[name].[ext]'
        }
      ],
    },
    resolve: {
      modules: ['deps', 'node_modules', path.resolve(__dirname, 'js')],
      extensions: ['.js'],
    },
    plugins: [
      new ExtractTextPlugin({
        filename: "css/[name].css"
      }),
      new CopyWebpackPlugin([{ from: "../priv/static" }])
    ]
  };
};
