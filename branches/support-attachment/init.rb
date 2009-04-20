# WPXML2TTXML ���� ����
# Jungtaek Lim(Heart)

require 'rexml/document'
include REXML

require 'wp_category'
require 'wp_post'
require 'wp_comment'
require 'wp_backup_parser'
require 'wp_to_tt_migrator'
require 'ttxml_writer'

# TAR2RUBYSCRIPT ��� �� ���丮 ��θ� �ӽ� ��ΰ� �ƴ� ���� ��η� ����
Dir.chdir oldlocation if defined?(TAR2RUBYSCRIPT)

# �������� üũ
unless ARGV.length == 2
  puts "Argument USAGE : <source file path(WordPress)> <target_file_path(TTXML)>"
  exit(-1)
end

source_file_path = ARGV[0]
target_file_path = ARGV[1]

# WPXML ������ XML Document �� �ε�
file = File.new source_file_path
doc = Document.new(file)

# WPXML �Ľ�
wp_backup_parser = WPBackupParser.new(doc)
wp_backup_parser.parse

# �Ľ̵� WPXML ������ ���� TTXML ������ ��ȯ
wp_to_tt_migrator = WPtoTTMigrator.new(
	wp_backup_parser.categories, wp_backup_parser.posts, wp_backup_parser.attachments
)

wp_to_tt_migrator.migrate

# ��ȯ�� TTXML ������ ���Ϸ� ����
ttxml_writer = TTXMLWriter.new(wp_to_tt_migrator.tt_categories, wp_to_tt_migrator.tt_posts)
ttxml_writer.write_to_file target_file_path
