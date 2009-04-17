# REXML ����� Ȱ���ϴ� ��ƿ��Ƽ ���
# Jungtaek Lim(Heart)

# REXML ����� Ȱ���ϴ� ��ƿ��Ƽ ���
module REXMLUtil

  # �ؽ�Ʈ Element ��ü �� �����
  # tag_name : �±� �� // String
  # text_value : �±��� ����(�ؽ�Ʈ) // String
  def make_xml_element(tag_name, text_value = nil)
    tag = Element.new tag_name

    tag.text = text_value if text_value != nil

    return tag
  end
end
