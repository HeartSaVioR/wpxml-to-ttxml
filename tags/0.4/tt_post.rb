# ���� �迭 ����Ʈ Ŭ����
# Jungtaek Lim(Heart)

# ���� �迭 ����Ʈ Ŭ����
# @id : ���� �ּ� // String
# @visibility : ���ü�(����, ����, ��ȣ, �����) // String
# @title : ���� // String
# @content : ���� // String
# @location : ���� // String
# @password : ����Ʈ�� �н�����(��ȣ��) // String
# @accept_comment : ��� ��� ���� // true/false
# @accept_trackback : Ʈ���� ��� ���� // true/false
# @publish_date : ������ �ð� // String
# @create_date : �ۼ� �ð� // String
# @modify_date : ���������� ������ �ð� // String
# @category : ����Ʈ�� ���� ī�װ� // TTCategory
# @tags : ����Ʈ�� ���� �±׵� // Array of String
# @comments : ����Ʈ�� ���� ��۵� // Array of TTComment
# @trackbacks : ����Ʈ�� ���� Ʈ����� // Array of TTTrackback
#
# * �ð��� 00:00:00 UTC on January 1, 1970 �������� ���� �ð� - sec
class TTPost
  attr_accessor :id, :visibility, :title, :content, :location, :password,
    :accept_comment, :accept_trackback, :publish_date, :create_date,
    :modify_date, :category, :tags, :comments, :trackbacks

  def initialize
    @comments = []
    @trackbacks = []
    @tags = []

  end

  # ��� �߰�
  # comment : ��� // TTComment
  def add_comment(comment)
    @comments.push(comment)

    @comments.sort! {|x, y| x.write_date <=> y.write_date }
  end

  # Ʈ���� �߰�
  # trackback : Ʈ���� // TTTrackback
  def add_trackback(trackback)
    @trackbacks.push(trackback)
  end

  # �±� �߰�
  # tag : �±� // String
  def add_tag(tag)
    @tags.push(tag)
  end

end
