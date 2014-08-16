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
    lng = float(cord[0])
    lat = float(cord[1])
    point = {'lat': lat, 'long': lng}
    return point


class PoiType(object):
    PT_VENUE = 0
    PT_UNI = 1
    PT_HOTEL = 2
    PT_HOTEL_2 = 3
    PT_TRANSPORT = 4
    PT_FOOD = 5

styleDict = {'#icon-503-4186F0': PoiType.PT_VENUE,
             '#icon-1035': PoiType.PT_HOTEL,
             '#icon-503-DB4436': PoiType.PT_FOOD,
             '#icon-1459': PoiType.PT_TRANSPORT}


def parse_style(text):
    if text not in styleDict:
        sys.stderr.write('[W] [%s] not in styleDict\n' % text)
        return PoiType.PT_FOOD
    return styleDict[text]


def parse_placemark(node):
    pm = {}
    for child in node.iterchildren():
        tag = child.tag[child.tag.rfind('}')+1:]
        if child.tag == '{http://www.opengis.net/kml/2.2}Point':
            coordinates_tag = child.getchildren()[0]
            pm['point'] = parse_point(coordinates_tag.text)
        elif child.tag == '{http://www.opengis.net/kml/2.2}styleUrl':
            pm['type'] = parse_style(child.text)
        else:
            pm[tag] = child.text.strip()

    return pm


def main():
    fd = file(sys.argv[1])
    doc = lxml.etree.parse(fd)
    kml = doc.getroot()
    if not kml.tag == '{http://www.opengis.net/kml/2.2}kml':
        print 'NOT A KML DOC!'
        return
    #Use XPath to get all the placemark tags in the document
    pmn = doc.xpath('//k:Placemark', namespaces={'k': 'http://www.opengis.net/kml/2.2'})
    placemarks = []
    for node in pmn:
        placemark = parse_placemark (node)
        placemarks.append (placemark)

    text = json.dumps(placemarks, sort_keys=True, indent=4)
    sys.stdout.write(text.encode('UTF-8'))


if __name__ == '__main__':
    main()
