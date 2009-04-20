# Jungtaek Lim(Heart)

# 워드프레스 첨부파일을 표현하는 클래스
# name : 파일명 // String
# attach_url : 첨부파일이 저장되어 있는 URL // String
# post_date : 등록 시각 // String
# width : 너비(이미지일 경우) // Number
# height : 높이(이미지일 경우) // Number
#
# 시각의 타입 : String(YYYY-MM-DD 24HR:MI:SS)
class WPAttachment
	attr_accessor :name, :attach_url, :post_date, :width, :height
	
	def initialize
		width = 0
		height = 0
		
	end
end
