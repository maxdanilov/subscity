require 'minitest/autorun'
require_relative '../test_utils'
require_relative '../../app/helpers/parser'

class TestKassaParser < Minitest::Test
  def setup
    @cls = KassaParser
  end

  def test_parse_date_time
    assert Time.new(2018, 2, 10, 20, 10), @cls.parse_date_time('2018-02-10T20:10:00')
  end

  def test_get_movie_id
    assert_equal @cls.get_movie_id('https://m.kassa.rambler.ru/msk/movie/51945?geoplaceid=2&widgetid=16857'), 51_945
  end

  def test_parse_movie_html
    data = get_fixture('movie_91971.htm')
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
    assert_equal result[:actors], 'Калеб Ландри Джонс, Вуди Харрельсон, Эбби Корниш, Сэм Рокуэлл'
    assert_equal result[:director], 'Мартин МакДонах'
    assert_equal result[:description], 'Спустя несколько месяцев после убийства дочери Милдред Хейс ' \
    'преступники так и не найдены. Отчаявшаяся женщина решается на смелый шаг, арендуя на въезде в город ' \
    'три билборда с посланием к авторитетному главе полиции Уильяму Уиллоуби. Когда в ситуацию оказывается ' \
    'втянут еще и заместитель шерифа, инфантильный маменькин сынок со склонностью к насилию, офицер Диксон, ' \
    'борьба между Милдред и властями города только усугубляется.'
  end

  def test_screening_date_time
    data = get_fixture('sessiondetails_34311975.json')
    result = @cls.screening_date_time(data)
    assert_equal Time.new(2018, 2, 10, 20, 10), result
  end

  def test_screening_movie_id
    data = get_fixture('sessiondetails_34311975.json')
    result = @cls.screening_movie_id(data)
    assert_equal 91_971, result
  end

  def test_screening_movie_id_empty
    result = @cls.screening_movie_id('{}')
    assert_nil result
  end

  def test_screening_has_subs
    data = get_fixture('sessiondetails_34311975.json')
    result = @cls.screening_has_subs?(data)
    assert_equal true, result
  end

  def test_screening_has_subs_empty
    result = @cls.screening_has_subs?('{}')
    assert_equal false, result
  end

  def test_screening_exists
    data = get_fixture('sessiondetails_34311975.json')
    result = @cls.screening_exists?(data)
    assert_equal true, result
  end

  def test_screening_exists_empty
    result = @cls.screening_exists?('{}')
    assert_equal false, result
  end

  def test_parser
    data = get_fixture('sessiondetails_34311975.json')
    result = @cls.parse_prices(data)
    assert_equal [500, 500], result
  end

  def test_parser_empty
    result = @cls.parse_prices('{}')
    assert_equal [nil, nil], result
  end
end
