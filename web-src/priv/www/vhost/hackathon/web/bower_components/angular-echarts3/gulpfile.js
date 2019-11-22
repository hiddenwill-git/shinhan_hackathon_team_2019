var gulp = require('gulp'),
    browserSync = require('browser-sync'),
    del = require('del'),
    rename = require('gulp-rename'),
    uglify = require('gulp-uglify');

var reload = browserSync.reload;

gulp.task('b', function() {
    gulp.src('./src/app/angular-echarts3.js')
        .pipe(gulp.dest('./dist'))
        .pipe(rename({ suffix: '.min' }))
        .pipe(uglify({
            mangle: {
                except: ['$window']
            }
        }))
        .pipe(gulp.dest('./dist'));
});

gulp.task('c', function() {
    del('./dist/*');
});

gulp.task('s', function() {
    browserSync.init({
        server: {
            baseDir: "./src",
            routes: {
                "/echarts": "bower_components/echarts",
                "/angular": "bower_components/angular/angular.min.js",
            }
        },
        files: ["./src/**/*.html", "./src/**/*.js"],
        ghostMode: {
            clicks: false,
            forms: false,
            scroll: false
        }
    });
});
