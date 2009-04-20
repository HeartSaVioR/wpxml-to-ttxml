# WPXML2TTXML 메인 파일
# Jungtaek Lim(Heart)

require 'rexml/document'
include REXML

require 'wp_category'
require 'wp_post'
require 'wp_comment'
require 'wp_backup_parser'
require 'wp_to_tt_migrator'
require 'ttxml_writer'

# TAR2RUBYSCRIPT 사용 시 디렉토리 경로를 임시 경로가 아닌 실행 경로로 변경
Dir.chdir oldlocation if defined?(TAR2RUBYSCRIPT)

# 전달인자 체크
unless ARGV.length == 2
  puts "Argument USAGE : <source file path(WordPress)> <target_file_path(TTXML)>"
  exit(-1)
end

source_file_path = ARGV[0]
target_file_path = ARGV[1]

# WPXML 파일을 XML Document 로 로딩
file = File.new source_file_path
doc = Document.new(file)

# WPXML 파싱
wp_backup_parser = WPBackupParser.new(doc)
wp_backup_parser.parse

# 파싱된 WPXML 정보를 토대로 TTXML 정보로 변환
wp_to_tt_migrator = WPtoTTMigrator.new(
	wp_backup_parser.categories, wp_backup_parser.posts, wp_backup_parser.attachments
)

wp_to_tt_migrator.migrate

# 변환된 TTXML 정보를 파일로 기입
ttxml_writer = TTXMLWriter.new(wp_to_tt_migrator.tt_categories, wp_to_tt_migrator.tt_posts)
ttxml_writer.write_to_file target_file_path
