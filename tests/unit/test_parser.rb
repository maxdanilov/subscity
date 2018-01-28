require 'minitest/autorun'
require_relative '../test_utils'
require_relative '../../app/helpers/parser'

class TestKassaParser < Minitest::Test
  def setup
    @cls = KassaParser
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
    data = get_fixture('session_33983268.htm')
    result = @cls.screening_date_time(data)

    assert_equal result, Time.new(2018, 2, 2, 11, 25)
  end
end
