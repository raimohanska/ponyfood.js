module.exports = (grunt) ->
  grunt.initConfig
    clean:
      dist: ['dist/']
      coffee: ['dist/*.coffee']

    coffee:
      compile:
        expand: true
        files: [
          'dist/Ponyfood.js': 'dist/Ponyfood.coffee'
          'dist/Ponyfood.min.js': 'dist/Ponyfood.noAssert.coffee'
        ]

    uglify:
      dist:
        files:
          'dist/Ponyfood.min.js': 'dist/Ponyfood.min.js'

    copy:
      dist:
        expand:true
        files:[
          'dist/Ponyfood.coffee': 'src/Ponyfood.coffee'
        ]
    replace:
      asserts:
        dest: 'dist/Ponyfood.noAssert.coffee'
        src: ['dist/Ponyfood.coffee']
        replacements: [
          from: /assert.*/g
          to: ''
        ]


  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-text-replace'

  grunt.registerTask 'build', ['clean:dist', 'copy', 'replace:asserts', 'coffee', 'uglify', 'clean:coffee']
  grunt.registerTask 'default', ['build']

  grunt.registerTask 'readme', 'Generate README.md', ->
    fs = require 'fs'
    readmedoc = require './readme-src.coffee'
    readmegen = require './readme/readme.coffee'
    fs.writeFileSync('README.md', readmegen readmedoc)
