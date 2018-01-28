require 'minitest/autorun'
require 'active_support/core_ext'
require_relative '../utils'
require_relative '../../app/helpers/parser'

class TestKassaParser < Minitest::Test
  def setup
    @cls = KassaParser
  end

  def test_get_movie_id
    assert_equal @cls.get_movie_id('https://m.kassa.rambler.ru/msk/movie/51945?geoplaceid=2&widgetid=16857'), 51_945
  end

  def test_parse_movie_html
    data = get_file_as_string('tests/fixtures/movie_91971.htm')
    result = @cls.parse_movie_html(data)
    assert !result.nil?
    assert_equal result[:title], 'Три билборда на границе Эббинга, Миссури'
    assert_equal result[:title_original], 'Three Billboards Outside Ebbing, Missouri'
    assert_equal result[:duration], 115
    assert_equal result[:year], 2017
    assert_equal result[:poster], 'https://img02.rl0.ru/kassa/c144x214q80i/s1.kassa.rl0.ru/StaticContent/P/Img/1801/17/180117100121928.jpg'
    assert_equal result[:country], 'США'
    assert_equal result[:genres], 'трагикомедия, криминальный'
    assert_equal result[:age_restriction], 18
  end
end
