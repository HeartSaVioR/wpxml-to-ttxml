# Jungtaek Lim(Heart)

# 태터계열 첨부파일을 표현하는 클래스
# name : 파일명 // String
# label : 업로드 시의 실제 파일명 // String
# attached : 등록 시각 // String
# content : 파일 내용(Base64 인코딩) // String
# mime : 첨부파일의 mime-type // String
# attach_size : 첨부파일의 인코딩 전 실제 크기 // Number
# width : 파일의 이미지 너비 // Number, 이미지가 아니면 0
# height : 파일의 이미지 높이 // Number, 이미지가 아니면 0
#
# 시각의 타입 : String(YYYY-MM-DD 24HR:MI:SS)
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
