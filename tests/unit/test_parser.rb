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
    assert_equal result[:year], 2018
    assert_equal result[:poster], 'https://img02.rl0.ru/kassa/c144x214q80i/s1.kassa.rl0.ru/StaticContent/P/Img/1801/17/180117100121928.jpg'
    assert_equal result[:country], 'США, Великобритания'
    assert_equal result[:genres], 'трагикомедия, криминальный'
    assert_equal result[:age_restriction], 18
    assert_equal result[:actors], 'Фрэнсис МакДорманд, Калеб Ландри Джонс, Керри Кондон, Сэм Рокуэлл'
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

  def test_parse_prices
    data = get_fixture('sessiontickets_34311975.json')
    result = @cls.parse_prices(data)
    assert_equal [300, 350], result
  end

  def test_parse_prices_empty
    result = @cls.parse_prices('{}')
    assert_equal [nil, nil], result
  end

  def test_parse_movie_sessions_empty
    result = @cls.parse_movie_sessions('{}', 1234)
    assert_equal [], result
  end

  def test_parse_movie_sessions
    data = get_fixture('moviesessions_91971.json')
    expected = [
      { session: 34_201_436, time: Time.new(2018, 2, 11, 19, 30), cinema: 567, movie: 1234, price: 360 },
      { session: 34_123_839, time: Time.new(2018, 2, 11, 13, 45), cinema: 397, movie: 1234, price: 250 }
    ]
    result = @cls.parse_movie_sessions(data, 1234)
    assert_equal expected, result
  end

  def test_parse_cinema_sessions_empty
    result = @cls.parse_cinema_sessions('{}', 123)
    assert_equal [], result
  end

  def test_parse_cinema_sessions
    data = get_fixture('cinemasessions_311.json')
    result = @cls.parse_cinema_sessions(data, 123)
    expected = [
      { session: 34_095_349, time: Time.new(2018, 2, 11, 18, 20), cinema: 123, movie: 91_971 },
      { session: 34_095_354, time: Time.new(2018, 2, 11, 11, 40), cinema: 123, movie: 91_744 },
      { session: 34_095_347, time: Time.new(2018, 2, 11, 13, 50), cinema: 123, movie: 91_744 },
      { session: 34_095_348, time: Time.new(2018, 2, 11, 16, 10), cinema: 123, movie: 91_744 },
      { session: 34_095_356, time: Time.new(2018, 2, 11, 18, 40), cinema: 123, movie: 91_744 },
      { session: 34_095_350, time: Time.new(2018, 2, 11, 20, 40), cinema: 123, movie: 91_744 },
      { session: 34_095_358, time: Time.new(2018, 2, 12, 1, 30), cinema: 123, movie: 91_744 },
      { session: 34_236_996, time: Time.new(2018, 2, 11, 9, 15), cinema: 123, movie: 94_418 },
      { session: 34_095_355, time: Time.new(2018, 2, 11, 14, 0), cinema: 123, movie: 93_982 },
      { session: 34_219_148, time: Time.new(2018, 2, 11, 20, 50), cinema: 123, movie: 93_982 },
      { session: 34_219_146, time: Time.new(2018, 2, 11, 22, 50), cinema: 123, movie: 89_948 },
      { session: 34_095_351, time: Time.new(2018, 2, 12, 1, 15), cinema: 123, movie: 94_169 },
      { session: 34_219_147, time: Time.new(2018, 2, 11, 16, 20), cinema: 123, movie: 94_347 }
    ]
    assert_equal expected, result
  end
end
