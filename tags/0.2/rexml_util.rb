# REXML 모듈을 활용하는 유틸리티 모듈
# Jungtaek Lim(Heart)

# REXML 모듈을 활용하는 유틸리티 모듈
module REXMLUtil

  # 텍스트 Element 객체 를 만든다
  # tag_name : 태그 명 // String
  # text_value : 태그의 내용(텍스트) // String
  def make_xml_element(tag_name, text_value = nil)
    tag = Element.new tag_name

    tag.text = text_value if text_value != nil

    return tag
  end
end
