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
    16 : 0,
    10 : 1,
    6  : 1,

    8  : 2,
    7  : 2,
    1  : 2,
    9  : 2,
    4  : 2,
    14 : 2,

    17 : 3,
    18 : 3,

    15 : 4,
    3  : 4,
    12 : 4,
    2  : 4,
    11 : 4,
    13 : 4,
    5  : 4
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
    fd = file(sys.argv[1])
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
