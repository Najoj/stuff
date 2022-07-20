"""
Generate some dates to be added in Calcurse's apts file.
"""

import calendar
import collections
import datetime
import math
import copy

veckodagar = mån, tis, ons, tor, fre, lör, sön = range(0, 7)
månader = jan, feb, mar, apr, maj, jun, jul, aug, sep, okt, nov, dec = range(1, 13)


def skottår(year: int) -> bool:
    """
    >>> skottår(1)
    False
    >>> skottår(4)
    True
    >>> skottår(100)
    True
    >>> skottår(400)
    True

    :param year: Year as int to test
    :return: True if leap year, False otherwise
    """
    div4 = year % 4 == 0
    div100 = year % 4 == 0
    div400 = year % 4 == 0
    return (div4 and not div100) or div400


def get_day_of_week(year, month, day):
    """
    >>> get_day_of_week(2022, 7, 18)
    0
    >>> get_day_of_week(2022, 7, 19)
    1
    >>> get_day_of_week(2022, 7, 20)
    2
    >>> get_day_of_week(2022, 7, 21)
    3
    >>> get_day_of_week(2022, 7, 22)
    4
    >>> get_day_of_week(2022, 7, 23)
    5
    >>> get_day_of_week(2022, 7, 24)
    6

    :param day:
    :param month:
    :param year:
    :return:
    """
    _date = f'{day} {month} {year}'
    return datetime.datetime.strptime(_date, '%d %m %Y').weekday()


class Date:
    def __init__(self, year, month, day, description=None):
        self.year = year
        self.month = month
        self.day = day
        self.description = description

        self.day_of_week = get_day_of_week(year, month, day)

        _is_leap_year = skottår(year)
        self._days_in_month = {jan: 31,
                               feb: 28 + (1 if _is_leap_year else 0),
                               mar: 31, apr: 30, maj: 31, jun: 30, jul: 31, aug: 31, sep: 30, okt: 31, nov: 30, dec: 31}

    def __add__(self, other: int):
        self.day += other
        self.day_of_week = (self.day_of_week + other) % 7
        if self.day > self._days_in_month[self.month]:
            self.day -= self._days_in_month[self.month]
            self.month += 1
            if self.month > 12:
                self.month -= 12
                self.year += 1
                self._days_in_month[feb] = 28
                if skottår(self.year):
                    self._days_in_month[feb] = 29
        return self

    def __sub__(self, other):
        self.day -= other
        self.day_of_week = (self.day_of_week - other + 7) % 7
        if self.day < 0:
            self.month -= 1
            self.day += self._days_in_month[self.month]
            if self.month < 1:
                self.month += 12
                self.year -= 1
                self._days_in_month[feb] = 28
                if skottår(self.year):
                    self._days_in_month[feb] = 29
        return self

    def __str__(self):
        m = self.month
        d = self.day
        y = self.year
        desc = self.description
        return f'{m}/{d}/{y} [1] {desc} (röd dag)'


def skärtorsdagen(year: int, description='') -> Date:
    # Torsdagen före Påskdagen
    _skärtorsdagen = påskdagen(year)
    _skärtorsdagen -= (sön - tor)
    _skärtorsdagen.description = description
    assert _skärtorsdagen.day_of_week == tor
    return _skärtorsdagen


def långfredagen(year: int, description='') -> Date:
    # Fredagen före Påskdagen
    _långfredagen = påskdagen(year)
    _långfredagen -= (sön - fre)
    _långfredagen.description = description
    assert _långfredagen.day_of_week == fre, _långfredagen.day_of_week
    return _långfredagen


def påskafton(year: int, description='') -> Date:
    # Lördagen före Påskdagen.
    _påskafton = påskdagen(year)
    _påskafton -= (sön - lör)
    _påskafton.description = description
    assert _påskafton.day_of_week == lör
    return _påskafton


_påskdagen = None


def påskdagen(year: int, description='') -> Date:
    # Första söndagen efter ecklesiastisk fullmåne, efter vårdagjämningen
    global _påskdagen
    if _påskdagen is None:
        # Gauss Easter Algorithm
        a = year % 19
        b = year % 4
        c = year % 7

        d = math.floor(year / 100)
        e = math.floor((13 + 8 * d) / 25)
        m = (15 - e + d - d // 4) % 30
        n = (4 + d - d // 4) % 7
        d = (19 * a + m) % 30
        e = (2 * b + 4 * c + 6 * d + n) % 7
        days = (22 + d + e)

        if (d == 29) and (e == 6):
            _påskdagen = Date(year, apr, 19)
        elif (d == 28) and (e == 6):
            _påskdagen = Date(year, apr, 18)
        else:
            # If days > 31, move to April
            if days > 31:
                days -= 31
                _påskdagen = Date(year, apr, days)
            else:
                _påskdagen = Date(year, mar, days)

    _påskdagen.description = description
    assert _påskdagen.day_of_week == sön, _påskdagen.day_of_week
    return copy.copy(_påskdagen)


def annandag_påsk(year: int, description='') -> Date:
    # Dagen efter påskdagen
    _annandag_påsk = påskdagen(year)
    _annandag_påsk += 1
    _annandag_påsk.description = description
    return _annandag_påsk


def kristi_himmelfärdsdag(year: int, description='') -> Date:
    # Sjätte torsdagen efter påskdagen
    _kristi_himmelfärdsdag = påskdagen(year)
    sixth = 0
    increment = 1
    while sixth != 6:
        _kristi_himmelfärdsdag += increment
        if _kristi_himmelfärdsdag.day_of_week == tor:
            sixth += 1
            increment = 7
    _kristi_himmelfärdsdag.description = description
    return _kristi_himmelfärdsdag


def pingstafton(year: int, description='') -> Date:
    # Dagen före pingstdagen
    _pingstafton = pingstdagen(year)
    _pingstafton -= 1
    _pingstafton.description = description
    return _pingstafton


def pingstdagen(year: int, description='') -> Date:
    # Sjunde söndagen efter påskdagen
    _pingstdagen = påskdagen(year)
    seventh = 0
    increment = 1
    while seventh != 7:
        _pingstdagen += increment
        if _pingstdagen.day_of_week == sön:
            seventh += 1
            increment = 7
    _pingstdagen.description = description
    return _pingstdagen


def midsommarafton(year: int, description='') -> Date:
    # Fredagen mellan 19 juni och 25 juni (fredagen före midsommardagen)
    _midsommarafton = midsommardagen(year)
    _midsommarafton -= 1
    _midsommarafton.description = description
    return _midsommarafton


def midsommardagen(year: int, description='') -> Date:
    # Lördagen mellan 20 juni och 26 juni
    _midsommardagen = Date(year, jun, 20)
    while _midsommardagen.day_of_week != lör:
        _midsommardagen += 1
    _midsommardagen.description = description
    return _midsommardagen


def allhelgonaafton(year: int, description='') -> Date:
    # Fredag mellan 30 oktober och 5 november
    _allhelgonaafton = alla_helgons_dag(year)
    _allhelgonaafton -= 1
    _allhelgonaafton.description = description
    return _allhelgonaafton


def alla_helgons_dag(year: int, description='') -> Date:
    # Lördagen som infaller under perioden från 31 oktober till 6 november
    _alla_helgons_dag = Date(year, okt, 31)
    while _alla_helgons_dag.day_of_week != lör:
        _alla_helgons_dag += 1
    _alla_helgons_dag.description = description
    return _alla_helgons_dag


def main():
    calendar.date = collections.namedtuple('Date', ['year', 'month', 'day'])
    år = datetime.datetime.now().date().strftime('%Y')
    år = int(år)

    red_days = [
        # Date(år, jan, 1),  # Nyårsdagen
        # Date(år, jan, 5),  # Trettondagsafton
        # Date(år, jan, 6),  # Trettondedag jul
        skärtorsdagen(år, 'Skärtorsdagen'),
        långfredagen(år, 'Långfredgan'),
        påskafton(år, 'Påskafton'),
        påskdagen(år, 'Påskdagen'),
        annandag_påsk(år, 'Annandag påsk'),
        # Date(år, apr, 30),  # Valborgsmässoafton
        # Date(år, maj, 1),  # Första maj
        kristi_himmelfärdsdag(år, 'Kristi himmelfärdsdag'),
        pingstafton(år, 'Pingstafton'),
        pingstdagen(år, 'Pingstdagen'),
        # Date(år, jun, 6),  # Sveriges nationaldag
        midsommarafton(år, 'Midsommmarafton'),
        midsommardagen(år, 'Midsommardagen'),
        allhelgonaafton(år, 'Allhelgonaafton'),
        alla_helgons_dag(år, 'Alla helgons dag'),
        # Date(år, dec, 24),  # Julafton
        # Date(år, dec, 25),  # Juldagen
        # Date(år, dec, 26),  # Annandag jul
        # Date(år, dec, 31),  # Nyårsafton
    ]
    for date in red_days:
        print(date)


if __name__ == '__main__':
    main()
