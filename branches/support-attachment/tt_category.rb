# ���� �迭 ī�װ� Ŭ����
# Jungtaek Lim(Heart)

# ���� �迭 ī�װ� Ŭ����
# @name : ī�װ� �� // String
# @children : ���� ī�װ� ����Ʈ // Array of String
class TTCategory
  attr_accessor :name, :children

  def initialize
    @name = nil
    @children = []

  end

  # ���� ī�װ� �߰�
  # child_category : ���� ī�װ� �� // String
  def add_child(child_category)
    @children.push(child_category)
    
  end
end
