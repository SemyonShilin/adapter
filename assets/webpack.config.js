const path = require('path');
const ExtractTextPlugin = require('extract-text-webpack-plugin');

module.exports = function(env) {
  const production = false;
  return {
    devServer: {
      headers: {
        'Access-Control-Allow-Origin': '*',
      },
    },
    devtool: production ? 'source-maps' : 'eval',
    entry: './js/app.js',
    output: production
      ? {
        path: path.resolve(__dirname, '../priv/static/js'),
        filename: 'app.js',
        publicPath: '/',
      }
      : {
        path: path.resolve(__dirname, '../priv/static/js'),
        filename: 'app.js',
        publicPath: 'http://localhost:8080/',
      },
    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: path.resolve(__dirname, "./node_modules"),
          use: {
            loader: 'babel-loader',
          },
        },
        {
          test: /\.(jpg|png)$/,
          use: {
            loader: 'file-loader',
            options: {
              name: "[name].[ext]",
              outputPath: path.resolve(__dirname, '../priv/static/images'),
              publicPath: 'http://localhost:8080/images'
            }
          }
        },
        {
          test: /\.(ttf|svg|woff2?|eot)$/,
<<<<<<< HEAD
          exclude: path.resolve(__dirname, "./fonts"),
          use: {
            loader: 'file-loader',
            options: {
              // name: "[name].[ext]",
=======
          exclude: path.resolve(__dirname, "./node_modules"),
          use: {
            loader: 'file-loader',
            options: {
              name: "[name].[ext]",
>>>>>>> 7ce6a89... temp
              outputPath: path.resolve(__dirname, '../priv/static/fonts'),
              publicPath: 'http://localhost:8080/fonts'
            }
          }
        },
        {
          test: /\.(scss|sass|css)$/i,
          use: ExtractTextPlugin.extract({
            fallback: 'style-loader',
            use: [
              { loader: 'css-loader', options: { minimize: false } },
              { loader: 'postcss-loader', options: { sourceMap: true } },
              { loader: 'resolve-url-loader'},
<<<<<<< HEAD
              { loader: 'sass-loader', options: { sourceMap: true,
                  includePaths: ["../fonts",
                    path.resolve(__dirname, '../priv/static/css'),
                    path.resolve(__dirname, '../fonts')] }
              },
            ],
            publicPath: 'http://localhost:8080/css'
          }),
=======
              { loader: 'sass-loader', options: { sourceMap: true } }
            ]
          })
>>>>>>> 7ce6a89... temp
        }

      ],
    },
    resolve: {
      modules: [path.resolve(__dirname, './node_modules'), path.resolve(__dirname, './js'),  path.resolve(__dirname, './css')],
      extensions: ['.js', '.css', '.scss'],
    },
    plugins: [
<<<<<<< HEAD
      new ExtractTextPlugin("./css/app.css")
=======
      new ExtractTextPlugin("app.css")
>>>>>>> 7ce6a89... temp
    ]
  };
};