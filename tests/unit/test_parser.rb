require 'minitest/autorun'
require_relative '../../app/helpers/parser'

class TestKassaParser < Minitest::Test
  def setup
    @cls = KassaParser
  end

  def test_get_movie_id
    assert_equal @cls.get_movie_id('https://m.kassa.rambler.ru/msk/movie/51945?geoplaceid=2&widgetid=16857'), 51_945
  end
end
