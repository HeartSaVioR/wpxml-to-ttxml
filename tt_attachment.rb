# Jungtaek Lim(Heart)

# ���Ͱ迭 ÷�������� ǥ���ϴ� Ŭ����
# name : ���ϸ� // String
# label : ���ε� ���� ���� ���ϸ� // String
# attached : ��� �ð� // String
# content : ���� ����(Base64 ���ڵ�) // String
# mime : ÷�������� mime-type // String
# attach_size : ÷�������� ���ڵ� �� ���� ũ�� // Number
# width : ������ �̹��� �ʺ� // Number, �̹����� �ƴϸ� 0
# height : ������ �̹��� ���� // Number, �̹����� �ƴϸ� 0
#
# �ð��� Ÿ�� : String(YYYY-MM-DD 24HR:MI:SS)
# 
class TTAttachment
	attr_accessor :name, :label, :attached, :content, :mime, 
	:attach_size, :width, :height
	
	def initialize
		width = 0
		height = 0
		attach_size = 0
	end
	
end
