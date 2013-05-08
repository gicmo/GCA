#!/usr/bin/env python

import lxml.etree
import json
import sys

class Foo(object):

    def __init__(self):
        self._locationManager = None

    @property
    def foo(self):
        if self._locationManager is None:
            self._locationManager = 'LocationManager'

        return self._locationManager

    @foo.setter
    def foo(self, value):
        self._locationManager = value


def parse_point(text):
    cord = text.split(',')
    long = float (cord[0])
    lat = float (cord[1])
    point = {'lat' : lat, 'long' : long}
    return point

styleDict = {
    5 : 0, #venue

    21 : 1, #uni
    13 : 1,
    25 : 1,

    7  : 2,
    8  : 2,
    14 : 2,
    23 : 2,
    24 : 2,
    16  : 2,

    22 : 3,
    1 : 3,
    3 : 3,
    17 : 3,
    18 : 3,
    9 : 3,

    10 : 4, #transport
    2  : 4,

    15 : 5, #food
    26 : 5,
    6 : 5,
    20 : 5,
    11 : 5,
    12 : 5,
    27 : 5,
    4 : 5,
    19 : 5
}

def parse_style(text):
    num = int(text[6:])
    return styleDict[num]

def parse_placemark(node):
    pm = {}
    for child in node.iterchildren():
        tag = child.tag[child.tag.rfind('}')+1:]
        if child.tag == '{http://earth.google.com/kml/2.2}Point':
            coordinates_tag = child.getchildren()[0]
            pm['point'] = parse_point(coordinates_tag.text)
        elif child.tag == '{http://earth.google.com/kml/2.2}styleUrl':
            pm['type'] = parse_style(child.text)
        else:
            pm[tag] = child.text

    return pm

def main():
    fd = file('BC12.kml')
    doc = lxml.etree.parse(fd)
    kml = doc.getroot()
    if not kml.tag == '{http://earth.google.com/kml/2.2}kml':
        print 'NOT A KML DOC!'
        return
    #Use XPath to get all the placemark tags in the document
    pmn = doc.xpath('//k:Placemark', namespaces={'k': 'http://earth.google.com/kml/2.2'})
    placemarks = []
    for node in pmn:
        placemark = parse_placemark (node)
        placemarks.append (placemark)

    text = json.dumps(placemarks, sort_keys=True, indent=4)
    sys.stdout.write(text.encode('UTF-8'))


if __name__ == '__main__':
    main()