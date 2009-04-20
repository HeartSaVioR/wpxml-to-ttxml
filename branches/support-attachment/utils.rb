# �۾� �ÿ� �ʿ��� ��ƿ��Ƽ �޼ҵ���� ����
# ���� �����丵�� �� �ִ�
# Jungtaek Lim(Heart)

require 'rubygems'

require 'open-uri'
require 'base64'

require 'image_size'

# URL �� ������ ��´�
# @url : URL �ּ�
# return : URL �� ����
def get_url_content(url)
  return open(url) {|io| io.read}
end

# ������ Base64 �� ���ڵ��Ѵ�
# @content : ����
# return : ������ Base64�� ���ڵ��� ���ڿ�
def content_to_base64_str(content)
  return Base64.encode64(content)
end

# �̹��� ������ ���� �̹��� ũ�⸦ ��´�
# @image_content : �̹��� ����
# return : �̹��� ũ�� �迭 [�ʺ�,����]
def get_image_size_from_content(image_content)
  return ImageSize.new(image_content).get_size	
end

