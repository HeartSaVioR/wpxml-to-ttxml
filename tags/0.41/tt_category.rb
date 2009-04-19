# 태터 계열 카테고리 클래스
# Jungtaek Lim(Heart)

# 태터 계열 카테고리 클래스
# @name : 카테고리 명 // String
# @children : 하위 카테고리 리스트 // Array of String
class TTCategory
  attr_accessor :name, :children

  def initialize
    @name = nil
    @children = []

  end

  # 하위 카테고리 추가
  # child_category : 하위 카테고리 명 // String
  def add_child(child_category)
    @children.push(child_category)
    
  end
end
