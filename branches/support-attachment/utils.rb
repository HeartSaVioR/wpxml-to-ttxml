# 작업 시에 필요한 유틸리티 메소드들을 정리
# 차후 리팩토링할 수 있다
# Jungtaek Lim(Heart)

require 'rubygems'

require 'open-uri'
require 'base64'

require 'image_size'

# URL 의 내용을 얻는다
# @url : URL 주소
# return : URL 의 내용
def get_url_content(url)
  return open(url) {|io| io.read}
end

# 내용을 Base64 로 인코딩한다
# @content : 내용
# return : 내용을 Base64로 인코딩한 문자열
def content_to_base64_str(content)
  return Base64.encode64(content)
end

# 이미지 내용을 토대로 이미지 크기를 얻는다
# @image_content : 이미지 내용
# return : 이미지 크기 배열 [너비,높이]
def get_image_size_from_content(image_content)
  return ImageSize.new(image_content).get_size	
end

