"""
Generate some dates to be added in Calcurse's apts file.
"""
import argparse
import calendar
import collections
import copy
import datetime
import math

veckodagar = man, tis, ons, tor, fre, loer, soen = range(0, 7)
maanader = jan, feb, mar, apr, maj, jun, jul, aug, sep, okt, nov, dec = range(1, 13)


def skottaar(year: int) -> bool:
    """
    >>> skottaar(1)
    False
    >>> skottaar(4)
    True
    >>> skottaar(100)
    True
    >>> skottaar(400)
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

        _is_leap_year = skottaar(year)
        self._days_in_month = {jan: 31,
                               feb: 28 + (1 if _is_leap_year else 0),
                               mar: 31, apr: 30, maj: 31, jun: 30, jul: 31, aug: 31, sep: 30, okt: 31, nov: 30, dec: 31}

    def __add__(self, other: int):
        """
        >>> d = Date(2022, 12, 31)
        >>> d.year, d.month, d.day, d._days_in_month[feb]
        (2022, 12, 31, 28)
        >>> d = d+1
        >>> d.year, d.month, d.day, d._days_in_month[feb]
        (2023, 1, 1, 28)
        >>> d = Date(2022, 2, 28)
        >>> d = d+3
        >>> d.year, d.month, d.day, d._days_in_month[feb]
        (2022, 3, 3, 28)
        >>> d = Date(2024, 2, 28)
        >>> d = d+3
        >>> d.year, d.month, d.day, d._days_in_month[feb]
        (2024, 3, 2, 29)
        >>> # 2024 är skottår
        >>> d = Date(2024, 1, 1)
        >>> d = d+365
        >>> d.year, d.month, d.day, d._days_in_month[feb]
        (2024, 12, 31, 29)
        >>> d = d+365
        >>> d.year, d.month, d.day, d._days_in_month[feb]
        (2025, 12, 31, 28)
        """
        self.day += other
        self.day_of_week = (self.day_of_week + other) % len(veckodagar)

        while self.day > self._days_in_month[self.month]:
            self.day -= self._days_in_month[self.month]
            self.month += 1
            if self.month > len(maanader):
                self.month -= len(maanader)
                self.year += 1
                self._days_in_month[feb] = 28
                if skottaar(self.year):
                    self._days_in_month[feb] = 29
        return self

    def __sub__(self, other):
        """
        >>> d = Date(2024, 1, 1)
        >>> d.year, d.month, d.day, d._days_in_month[feb]
        (2024, 1, 1, 29)
        >>> d = d-1
        >>> d.year, d.month, d.day, d._days_in_month[feb]
        (2023, 12, 31, 28)
        >>> d = Date(2022, 3, 3)
        >>> d = d-3
        >>> d.year, d.month, d.day, d._days_in_month[feb]
        (2022, 2, 28, 28)
        >>> d = Date(2024, 3, 2)
        >>> d = d-3
        >>> d.year, d.month, d.day, d._days_in_month[feb]
        (2024, 2, 28, 29)
        >>> # 2024 är skottår
        >>> d = Date(2025, 12, 31)
        >>> d = d-365
        >>> d.year, d.month, d.day, d._days_in_month[feb]
        (2024, 12, 31, 29)
        >>> d = d-365
        >>> d.year, d.month, d.day, d._days_in_month[feb]
        (2024, 1, 1, 29)
        """
        self.day -= other
        self.day_of_week = (self.day_of_week - other) % len(veckodagar)
        while self.day < 1:
            self.month -= 1

            if self.month < 1:
                self.month += len(maanader)
                self.year -= 1
                self._days_in_month[feb] = 28
                if skottaar(self.year):
                    self._days_in_month[feb] = 29

            self.day += self._days_in_month[self.month]
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

        return f'{m:02d}/{d:02d}/{y:02d} [1]{yearly}{desc}'

    def __lt__(self, other) -> bool:
        if not type(other) == type(self):
            return False

        if other.year < self.year:
            return True
        elif other.year > self.year:
            return False

        if other.month < self.month:
            return True
        elif other.month > self.month:
            return False

        if other.day < self.day:
            return True
        elif other.day > self.day:
            return False

        return False

def skaertorsdagen(year: int) -> Date:
    """
    >>> d = skaertorsdagen(2022)
    >>> d.year, d.month, d.day
    (2022, 4, 14)
    >>> d = skaertorsdagen(2000)
    >>> d.year, d.month, d.day
    (2000, 4, 20)
    >>> d = skaertorsdagen(1990)
    >>> d.year, d.month, d.day
    (1990, 4, 12)
    >>> d = skaertorsdagen(1988)
    >>> d.year, d.month, d.day
    (1988, 3, 31)
    """
    # Torsdagen före Påskdagen
    _skaertorsdagen = paaskdagen(year)
    _skaertorsdagen -= (soen - tor)

    _skaertorsdagen.description = 'Skärtorsdagen'
    _skaertorsdagen.flag_day = False
    _skaertorsdagen.red_day = False

    assert _skaertorsdagen.day_of_week == tor
    return _skaertorsdagen


def laangfredagen(year: int) -> Date:
    """
    >>> d = laangfredagen(2022)
    >>> d.year, d.month, d.day
    (2022, 4, 15)
    >>> d = laangfredagen(2000)
    >>> d.year, d.month, d.day
    (2000, 4, 21)
    >>> d = laangfredagen(1990)
    >>> d.year, d.month, d.day
    (1990, 4, 13)
    >>> d = laangfredagen(1988)
    >>> d.year, d.month, d.day
    (1988, 4, 1)
    """
    # Fredagen före Påskdagen
    _laangfredagen = paaskdagen(year)
    _laangfredagen -= (soen - fre)

    _laangfredagen.description = 'Långfredgan'
    _laangfredagen.flag_day = False
    _laangfredagen.red_day = True

    assert _laangfredagen.day_of_week == fre, _laangfredagen.day_of_week
    return _laangfredagen


def paaskafton(year: int) -> Date:
    """
    >>> d = paaskafton(2022)
    >>> d.year, d.month, d.day
    (2022, 4, 16)
    >>> d = paaskafton(2000)
    >>> d.year, d.month, d.day
    (2000, 4, 22)
    >>> d = paaskafton(1990)
    >>> d.year, d.month, d.day
    (1990, 4, 14)
    >>> d = laangfredagen(1988)
    >>> d.year, d.month, d.day
    (1988, 4, 1)
    """
    # Lördagen före Påskdagen.
    _paaskafton = paaskdagen(year)
    _paaskafton -= (soen - loer)

    _paaskafton.description = 'Påskafton'
    _paaskafton.flag_day = False
    _paaskafton.red_day = True

    assert _paaskafton.day_of_week == loer
    return _paaskafton


_paaskdagen = None


def paaskdagen(year: int, force=False) -> Date:
    """
    >>> d = paaskdagen(2022)
    >>> d.year, d.month, d.day
    (2022, 4, 17)
    >>> d = paaskdagen(2000)
    >>> d.year, d.month, d.day
    (2000, 4, 23)
    >>> d = paaskdagen(1990)
    >>> d.year, d.month, d.day
    (1990, 4, 15)
    >>> d = paaskdagen(1988)
    >>> d.year, d.month, d.day
    (1988, 4, 3)
    """

    # Första söndagen efter ecklesiastisk fullmåne, efter vårdagjämningen
    global _paaskdagen
    if _paaskdagen is None or _paaskdagen.year != year:
        # Gauss' Easter Algorithm
        a = year % 19
        b = year % 4
        c = year % 7

        d = math.floor(year / 100)
        e = math.floor((13 + 8 * d) / 25)
        m = (15 - e + d - d // 4) % 30
        n = (4 + d - d // 4) % 7
        d = (19 * a + m) % 30
        e = (2 * b + 4 * c + 6 * d + n) % 7
        day = (22 + d + e)

        if (d == 29) and (e == 6):
            _paaskdagen = Date(year, apr, 19)
        elif (d == 28) and (e == 6):
            _paaskdagen = Date(year, apr, 18)
        else:
            # If day > 31, move to April
            if day > 31:
                day -= 31
                _paaskdagen = Date(year, apr, day)
            else:
                _paaskdagen = Date(year, mar, day)

    _paaskdagen.description = 'Påskdagen'
    _paaskdagen.flag_day = True
    _paaskdagen.red_day = True

    assert _paaskdagen.day_of_week == soen, _paaskdagen.day_of_week
    return copy.copy(_paaskdagen)


def annandag_paask(year: int) -> Date:
    """
    >>> d = annandag_paask(2022)
    >>> d.year, d.month, d.day
    (2022, 4, 18)
    >>> d = annandag_paask(2000)
    >>> d.year, d.month, d.day
    (2000, 4, 24)
    >>> d = annandag_paask(1990)
    >>> d.year, d.month, d.day
    (1990, 4, 16)
    >>> d = annandag_paask(1988)
    >>> d.year, d.month, d.day
    (1988, 4, 4)
    """
    # Dagen efter påskdagen
    _annandag_paask = paaskdagen(year)
    _annandag_paask += 1

    _annandag_paask.description = 'Annandag påsk'
    _annandag_paask.red_day = True
    _annandag_paask.flag_day = False

    return _annandag_paask


def kristi_himmelfaerdsdag(year: int) -> Date:
    """
    >>> d = pingstafton(2022)
    >>> d.year, d.month, d.day
    (2022, 5, 28)
    >>> d = pingstafton(2000)
    >>> d.year, d.month, d.day
    (2000, 6, 3)
    >>> d = pingstafton(1990)
    >>> d.year, d.month, d.day
    (1990, 5, 26)
    >>> d = pingstafton(1988)
    >>> d.year, d.month, d.day
    (1988, 5, 14)
    """
    # Sjätte torsdagen efter påskdagen
    _kristi_himmelfaerdsdag = paaskdagen(year)

    sixth = 1 if _kristi_himmelfaerdsdag.day_of_week == tor else 0
    increment = 1
    while sixth != 6:
        _kristi_himmelfaerdsdag += increment
        if _kristi_himmelfaerdsdag.day_of_week == tor:
            sixth += 1
            increment = len(veckodagar)

    _kristi_himmelfaerdsdag.description = 'Kristi himmelfärdsdag'
    _kristi_himmelfaerdsdag.red_day = True
    _kristi_himmelfaerdsdag.flag_day = False

    return _kristi_himmelfaerdsdag


def pingstafton(year: int) -> Date:
    """
    >>> d = pingstafton(2022)
    >>> d.year, d.month, d.day
    (2022, 5, 28)
    >>> d = pingstafton(2000)
    >>> d.year, d.month, d.day
    (2000, 6, 3)
    >>> d = pingstafton(1990)
    >>> d.year, d.month, d.day
    (1990, 5, 26)
    >>> d = pingstafton(1988)
    >>> d.year, d.month, d.day
    (1988, 5, 14)
    """
    # Dagen före pingstdagen
    _pingstafton = pingstdagen(year)
    _pingstafton -= 1

    _pingstafton.description = 'Pingstafton'
    _pingstafton.red_day = True
    _pingstafton.flag_day = False

    return _pingstafton


def pingstdagen(year: int) -> Date:
    """
    >>> d = pingstdagen(2022)
    >>> d.year, d.month, d.day
    (2022, 5, 29)
    >>> d = pingstdagen(2000)
    >>> d.year, d.month, d.day
    (2000, 6, 4)
    >>> d = pingstdagen(1990)
    >>> d.year, d.month, d.day
    (1990, 5, 27)
    >>> d = pingstdagen(1988)
    >>> d.year, d.month, d.day
    (1988, 5, 15)
    """
    # Sjunde söndagen efter påskdagen
    _pingstdagen = paaskdagen(year)
    seventh = 1 if _pingstdagen.day_of_week == soen else 0
    increment = 1
    while seventh != 7:
        _pingstdagen += increment
        if _pingstdagen.day_of_week == soen:
            seventh += 1
            increment = len(veckodagar)

    _pingstdagen.description = 'Pingstdagen'
    _pingstdagen.red_day = True
    _pingstdagen.flag_day = True

    return _pingstdagen


def midsommarafton(year: int) -> Date:
    """
    >>> d = midsommarafton(2022)
    >>> d.year, d.month, d.day
    (2022, 6, 24)
    >>> d = midsommarafton(2000)
    >>> d.year, d.month, d.day
    (2000, 6, 23)
    >>> d = midsommarafton(1990)
    >>> d.year, d.month, d.day
    (1990, 6, 22)
    >>> d = midsommarafton(1988)
    >>> d.year, d.month, d.day
    (1988, 6, 24)
    """
    # Fredagen mellan 19 juni och 25 juni (fredagen före midsommardagen)
    _midsommarafton = midsommardagen(year)
    _midsommarafton -= 1

    _midsommarafton.description = 'Midsommmarafton'
    _midsommarafton.red_day = False
    _midsommarafton.flag_day = False

    return _midsommarafton


def midsommardagen(year: int) -> Date:
    """
    >>> d = midsommardagen(2022)
    >>> d.year, d.month, d.day
    (2022, 6, 25)
    >>> d = midsommardagen(2000)
    >>> d.year, d.month, d.day
    (2000, 6, 24)
    >>> d = midsommardagen(1990)
    >>> d.year, d.month, d.day
    (1990, 6, 23)
    >>> d = midsommardagen(1988)
    >>> d.year, d.month, d.day
    (1988, 6, 25)
    """
    # Lördagen mellan 20 juni och 26 juni
    _midsommardagen = Date(year, jun, 20)
    while _midsommardagen.day_of_week != loer:
        _midsommardagen += 1

    _midsommardagen.description = 'Midsommardagen'
    _midsommardagen.red_day = True
    _midsommardagen.flag_day = True

    return _midsommardagen


def allhelgonaafton(year: int) -> Date:
    """
    >>> d = allhelgonaafton(2022)
    >>> d.year, d.month, d.day
    (2022, 11, 4)
    >>> d = allhelgonaafton(2000)
    >>> d.year, d.month, d.day
    (2000, 11, 3)
    >>> d = allhelgonaafton(1990)
    >>> d.year, d.month, d.day
    (1990, 11, 2)
    >>> d = allhelgonaafton(1988)
    >>> d.year, d.month, d.day
    (1988, 11, 4)
    """
    # Fredag mellan 30 oktober och 5 november
    _allhelgonaafton = alla_helgons_dag(year)
    _allhelgonaafton -= 1

    _allhelgonaafton.description = 'Allhelgonaafton'
    _allhelgonaafton.red_day = True
    _allhelgonaafton.flag_day = False

    return _allhelgonaafton


def alla_helgons_dag(year: int) -> Date:
    """
    >>> d = alla_helgons_dag(2022)
    >>> d.year, d.month, d.day
    (2022, 11, 5)
    >>> d = alla_helgons_dag(2000)
    >>> d.year, d.month, d.day
    (2000, 11, 4)
    >>> d = alla_helgons_dag(1990)
    >>> d.year, d.month, d.day
    (1990, 11, 3)
    >>> d = alla_helgons_dag(1988)
    >>> d.year, d.month, d.day
    (1988, 11, 5)
    """
    # Lördagen som infaller under perioden från 31 oktober till 6 november
    _alla_helgons_dag = Date(year, okt, 31)
    while _alla_helgons_dag.day_of_week != loer:
        _alla_helgons_dag += 1

    _alla_helgons_dag.description = 'Alla helgons dag'
    _alla_helgons_dag.red_day = True
    _alla_helgons_dag.flag_day = False

    return _alla_helgons_dag


def mors_dag(year: int) -> Date:
    """
    >>> d = mors_dag(2024)
    >>> d.year, d.month, d.day
    (2024, 5, 26)
    """
    # Sista söndagen i maj
    _mors_dag = Date(year, maj, 31)
    while _mors_dag.day_of_week != soen:
        _mors_dag -= 1

    _mors_dag.description = 'Mors dag'
    _mors_dag.red_day = False
    _mors_dag.flag_day = False

    return _mors_dag


def fars_dag(year: int) -> Date:
    """
    >>> d = fars_dag(2024)
    >>> d.year, d.month, d.day
    (2024, 11, 10)
    """
    # Andra söndagen i november
    _fars_dag = Date(year, nov, 8)
    while _fars_dag.day_of_week != soen:
        _fars_dag += 1

    _fars_dag.description = 'Fars dag'
    _fars_dag.red_day = False
    _fars_dag.flag_day = False

    return _fars_dag

def valaar(year):
    """
    Only valid from 1994 and forward.

    >>> valaar(2022)
    True
    >>> valaar(2023)
    False
    """
    return 2 == year % 4


def valdagen(year):
    """
    Check to see if election year has to be made before call.
    Only valid since 2008

    >>> d = valdagen(2022)
    >>> d.year, d.month, d.day
    (2022, 9, 11)
    >>> d = valdagen(2026)
    >>> d.year, d.month, d.day
    (2026, 9, 13)
    """
    # Andra söndagen i september, vid valår
    _valdagen = Date(year, sep, 1, description='Valdagen', red=False, flag=True)

    second = 1 if _valdagen.day_of_week == soen else 0
    increment = 1
    while second != 2:
        _valdagen += increment
        if _valdagen.day_of_week == soen:
            second += 1
            increment = len(veckodagar)

    return _valdagen


def main(aar: int):
    dates = [
        ## Januari
        # Varje år
        Date(0, jan, 1, description='Nyårsdagen', red=True, flag=True),
        Date(0, jan, 5, description='Trettondagsafton', red=True, flag=False),
        Date(0, jan, 6, description='Trettondedag jul', red=True, flag=False),
        Date(0, jan, 28, description='Konungens namnsdag', red=False, flag=True),
        ## Februari
        ## Mars
        # Varje år
        Date(0, mar, 8, description='Internationella kvinnodagen', red=False, flag=False),
        Date(0, mar, 10, description='Mario-dagen', red=False, flag=False),
        Date(0, mar, 14, description='π-dagen', red=False, flag=False),
        # April, typ
        skaertorsdagen(aar),
        laangfredagen(aar),
        paaskafton(aar),
        paaskdagen(aar),
        annandag_paask(aar),
        # Varje år
        Date(0, apr, 30, description='Valborgsmässoafton', red=True, flag=False),
        Date(1946, apr, 30, description='Konungens födelsedag', red=False, flag=True),
        ## Maj
        # Varje år
        Date(0, maj, 1, description='Första maj', red=True, flag=True),
        # Varje år
        Date(0, maj, 29, description='Veterandagen', red=False, flag=True),
        mors_dag(aar),
        ## April, juni
        kristi_himmelfaerdsdag(aar),
        pingstafton(aar),
        pingstdagen(aar),
        ## Juni
        Date(aar, jun, 6, description='Sveriges nationaldag', red=True, flag=True),
        midsommarafton(aar),
        midsommardagen(aar),
        # Juli
        Date(1977, jul, 14, description='Kronprinsessans födelsedag', red=False, flag=True),
        ## Augusti
        # Varje år
        Date(0, aug, 8, description='Drottningens namnsdag', red=False, flag=True),
        ## September
        ## Oktober
        Date(0, okt, 11, description='Internationella kvinnodagen', red=False, flag=False),
        Date(0, okt, 24, description='FN-dagen', red=False, flag=True),
        ## November
        Date(0, nov, 6, description='Gustav Adolfsdagen', red=False, flag=True),
        Date(0, nov, 19, description='Internationella mansdagen', red=False, flag=False),
        Date(0, nov, 25, description='Internationella mansdagen', red=False, flag=False),
        
        fars_dag(aar),
        allhelgonaafton(aar),
        alla_helgons_dag(aar),
        ## December
        Date(1943, dec, 23, description='Drottningens födelsedag', red=False, flag=True),
        # Varje år
        Date(0, dec, 10, description='Nobeldagen', red=False, flag=True),
        Date(0, dec, 24, description='Julafton', red=True, flag=False),
        Date(0, dec, 25, description='Juldagen', red=True, flag=True),
        Date(0, dec, 26, description='Annandag jul', red=True, flag=False),
        Date(0, dec, 31, description='Nyårsafton', red=True, flag=False),
    ]
    if valaar(aar):
        dates.append(valdagen(aar))

    for date in sorted(dates, reverse=True):
        print(date)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('aar', nargs='?', const='c')
    arguments = parser.parse_args()

    if arguments.aar is None:
        calendar.date = collections.namedtuple('Date', ['year', 'month', 'day'])
        aar = datetime.datetime.now().date().strftime('%Y')
        aar = int(aar)
    else:
        aar = int(arguments.aar)
    main(aar)

