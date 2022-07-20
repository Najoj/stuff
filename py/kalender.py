"""
Generate some dates to be added in Calcurse's apts file.
"""

import calendar
import collections
import copy
import datetime
import math

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
    def __init__(self, year, month, day,
                 description=None, red=False, flag=False):
        self.year = year
        self.month = month
        self.day = day

        self.description = description
        self.red_day = red
        self.flag_day = flag

        self.day_of_week = 0 if year == 0 else get_day_of_week(year, month, day)

        _is_leap_year = skottår(year)
        self._days_in_month = {jan: 31,
                               feb: 28 + (1 if _is_leap_year else 0),
                               mar: 31, apr: 30, maj: 31, jun: 30, jul: 31, aug: 31, sep: 30, okt: 31, nov: 30, dec: 31}

    def __add__(self, other: int):
        self.day += other
        self.day_of_week = (self.day_of_week + other) % len(veckodagar)
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
        self.day_of_week = (self.day_of_week - other) % len(veckodagar)
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

        # If year was set to
        yearly = ' {1Y} ' if y == 0 else ' '
        y = 1970 if y == 0 else y

        if self.red_day and self.flag_day:
            desc += ' (röd dag och flaggdag)'
        elif self.red_day:
            desc += ' (röd dag)'
        elif self.flag_day:
            desc += ' (flaggdag)'

        return f'{m}/{d}/{y} [1]{yearly}{desc}'


def skärtorsdagen(year: int) -> Date:
    # Torsdagen före Påskdagen
    _skärtorsdagen = påskdagen(year)
    _skärtorsdagen -= (sön - tor)

    _skärtorsdagen.description = 'Skärtorsdagen'
    _skärtorsdagen.flag_day = False
    _skärtorsdagen.red_day = True

    assert _skärtorsdagen.day_of_week == tor
    return _skärtorsdagen


def långfredagen(year: int) -> Date:
    # Fredagen före Påskdagen
    _långfredagen = påskdagen(year)
    _långfredagen -= (sön - fre)

    _långfredagen.description = 'Långfredgan'
    _långfredagen.flag_day = False
    _långfredagen.red_day = True

    assert _långfredagen.day_of_week == fre, _långfredagen.day_of_week
    return _långfredagen


def påskafton(year: int) -> Date:
    # Lördagen före Påskdagen.
    _påskafton = påskdagen(year)
    _påskafton -= (sön - lör)

    _påskafton.description = 'Påskafton'
    _påskafton.flag_day = False
    _påskafton.red_day = True

    assert _påskafton.day_of_week == lör
    return _påskafton


_påskdagen = None


def påskdagen(year: int) -> Date:
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

    _påskdagen.description = 'Påskdagen'
    _påskdagen.flag_day = True
    _påskdagen.red_day = True

    assert _påskdagen.day_of_week == sön, _påskdagen.day_of_week
    return copy.copy(_påskdagen)


def annandag_påsk(year: int) -> Date:
    # Dagen efter påskdagen
    _annandag_påsk = påskdagen(year)
    _annandag_påsk += 1

    _annandag_påsk.description = 'Annandag påsk'
    _annandag_påsk.red_day = True
    _annandag_påsk.flag_day = False

    return _annandag_påsk


def kristi_himmelfärdsdag(year: int) -> Date:
    # Sjätte torsdagen efter påskdagen
    _kristi_himmelfärdsdag = påskdagen(year)

    sixth = 1 if _kristi_himmelfärdsdag.day_of_week == tor else 0
    increment = 1
    while sixth != 6:
        _kristi_himmelfärdsdag += increment
        if _kristi_himmelfärdsdag.day_of_week == tor:
            sixth += 1
            increment = len(veckodagar)

    _kristi_himmelfärdsdag.description = 'Kristi himmelfärdsdag'
    _kristi_himmelfärdsdag.red_day = True
    _kristi_himmelfärdsdag.flag_day = False

    return _kristi_himmelfärdsdag


def pingstafton(year: int) -> Date:
    # Dagen före pingstdagen
    _pingstafton = pingstdagen(year)
    _pingstafton -= 1

    _pingstafton.description = 'Pingstafton'
    _pingstafton.red_day = True
    _pingstafton.flag_day = False

    return _pingstafton


def pingstdagen(year: int) -> Date:
    # Sjunde söndagen efter påskdagen
    _pingstdagen = påskdagen(year)
    seventh = 1 if _pingstdagen.day_of_week == sön else 0
    increment = 1
    while seventh != 7:
        _pingstdagen += increment
        if _pingstdagen.day_of_week == sön:
            seventh += 1
            increment = len(veckodagar)

    _pingstdagen.description = 'Pingstdagen'
    _pingstdagen.red_day = True
    _pingstdagen.flag_day = True

    return _pingstdagen


def midsommarafton(year: int) -> Date:
    # Fredagen mellan 19 juni och 25 juni (fredagen före midsommardagen)
    _midsommarafton = midsommardagen(year)
    _midsommarafton -= 1

    _midsommarafton.description = 'Midsommmarafton'
    _midsommarafton.red_day = True
    _midsommarafton.flag_day = False

    return _midsommarafton


def midsommardagen(year: int) -> Date:
    # Lördagen mellan 20 juni och 26 juni
    _midsommardagen = Date(year, jun, 20)
    while _midsommardagen.day_of_week != lör:
        _midsommardagen += 1

    _midsommardagen.description = 'Midsommardagen'
    _midsommardagen.red_day = True
    _midsommardagen.flag_day = True

    return _midsommardagen


def allhelgonaafton(year: int) -> Date:
    # Fredag mellan 30 oktober och 5 november
    _allhelgonaafton = alla_helgons_dag(year)
    _allhelgonaafton -= 1

    _allhelgonaafton.description = 'Allhelgonaafton'
    _allhelgonaafton.red_day = True
    _allhelgonaafton.flag_day = False

    return _allhelgonaafton


def alla_helgons_dag(year: int) -> Date:
    # Lördagen som infaller under perioden från 31 oktober till 6 november
    _alla_helgons_dag = Date(year, okt, 31)
    while _alla_helgons_dag.day_of_week != lör:
        _alla_helgons_dag += 1

    _alla_helgons_dag.description = 'Alla helgons dag'
    _alla_helgons_dag.red_day = True
    _alla_helgons_dag.flag_day = False

    return _alla_helgons_dag


def valår(year):
    return 2 == year % 4


def valdagen(year):
    # Andra söndagen i september, vid valår
    _valdagen = Date(year, sep, 1, description='Valdagen', red=False, flag=True)

    second = 1 if _valdagen.day_of_week == sön else 0
    increment = 1
    while second != 2:
        _valdagen += increment
        if _valdagen.day_of_week == sön:
            second += 1
            increment = len(veckodagar)

    return _valdagen

def main():
    calendar.date = collections.namedtuple('Date', ['year', 'month', 'day'])
    år = datetime.datetime.now().date().strftime('%Y')
    år = int(år)

    dates = [
        Date(0, jan, 1, description='Nyårsdagen', red=True, flag=True),
        Date(0, jan, 5, description='Trettondagsafton', red=True, flag=False),
        Date(0, jan, 6, description='Trettondedag jul', red=True, flag=False),
        Date(0, jan, 28, description='Konungens namnsdag', red=False, flag=True),

        skärtorsdagen(år),
        långfredagen(år),
        påskafton(år),
        påskdagen(år),
        annandag_påsk(år),

        Date(år, apr, 30, description='Valborgsmässoafton', red=True, flag=False),
        Date(0, apr, 30, description='Konungens födelsedag', red=False, flag=True),

        Date(år, maj, 1, description='Första maj', red=True, flag=True),
        Date(0, maj, 29, description='Veterandagen', red=False, flag=True),

        kristi_himmelfärdsdag(år),
        pingstafton(år),
        pingstdagen(år),

        Date(år, jun, 6, description='Sveriges nationaldag', red=True, flag=True),

        midsommarafton(år),
        midsommardagen(år),

        Date(0, jul, 14, description='Kronprinsessans födelsedag', red=False, flag=True),
        Date(0, aug, 8, description='Drottningens namnsdag', red=False, flag=True),
        Date(0, okt, 24, description='FN-dagen', red=False, flag=True),
        Date(0, nov, 6, description='Gustav Adolfsdagen', red=False, flag=True),

        allhelgonaafton(år),
        alla_helgons_dag(år),

        Date(0, dec, 10, description='Nobeldagen', red=False, flag=True),

        Date(0, dec, 23, description='Drottningens födelsedag', red=False, flag=True),
        Date(år, dec, 24, description='Julafton', red=True, flag=False),
        Date(år, dec, 25, description='Juldagen', red=True, flag=True),
        Date(år, dec, 26, description='Annandag jul', red=True, flag=False),
        Date(år, dec, 31, description='Nyårsafton', red=True, flag=False),
    ]
    for date in dates:
        print(date)

    if valår(år):
        print(valdagen(år))


if __name__ == '__main__':
    main()
