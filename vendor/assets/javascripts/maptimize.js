(function() {
  var _base;

  if (this.com == null) {
    this.com = {};
  }

  if ((_base = this.com).maptimize == null) {
    _base.maptimize = {
      MAPTIMIZE_URL: "http://v2.maptimize.com/api/v2-1/",
      ASSET_URL: "images/"
    };
  }

}).call(this);
(function() {

  com.maptimize.Cluster = (function() {

    Cluster.name = 'Cluster';

    function Cluster(data, map) {
      this.data = data;
      this.map = map;
      this.mapSystem = map.mapSystem;
      if (this.latLng == null) {
        this.latLng = this.mapSystem.latLngFromString(this.data.coords);
      }
      if (this.bounds == null) {
        this.bounds = this.mapSystem.buildLatLngBounds(this.mapSystem.latLngFromString(this.data.bounds.sw), this.mapSystem.latLngFromString(this.data.bounds.ne));
      }
    }

    Cluster.prototype.count = function() {
      return this.data.count;
    };

    Cluster.prototype.getAggregates = function() {
      return this.data;
    };

    Cluster.prototype.paramsForAggregate = function(type) {
      var params;
      params = this.map.paramsForRequest();
      params.aggregates = "concat(" + type + ")";
      params.sw = this.mapSystem.getUrlValue(this.bounds.getSouthWest(), -0.0001);
      params.ne = this.mapSystem.getUrlValue(this.bounds.getNorthEast(), +0.0001);
      return params;
    };

    Cluster.prototype.ids = function(callback) {
      return new com.maptimize.Request(this.map.getUrl('clusterize'), this.paramsForAggregate('id'), {
        context: this,
        success: function(response) {
          return callback(response.clusters[0]["concat(id)"]);
        }
      }).post();
    };

    Cluster.prototype.html = function(callback) {
      return new com.maptimize.Request(this.map.getUrl('clusterize'), this.paramsForAggregate('html'), {
        context: this,
        success: function(response) {
          return callback(response.clusters[0]["concat(html)"]);
        }
      }).post();
    };

    Cluster.prototype.zoomable = function(accuracy) {
      var ne, sw;
      if (accuracy == null) {
        accuracy = 0.000001;
      }
      ne = this.bounds.getNorthEast();
      sw = this.bounds.getSouthWest();
      return (this.mapSystem.getLat(ne) - this.mapSystem.getLat(sw)) > accuracy;
    };

    return Cluster;

  })();

}).call(this);
(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  com.maptimize.Condition = (function() {

    Condition.name = 'Condition';

    Condition.prototype.SPECIAL_CHARS = {
      '\b': '\\b',
      '\t': '\\t',
      '\n': '\\n',
      '\f': '\\f',
      '\r': '\\r',
      '\\': '\\\\'
    };

    function Condition(condition) {
      this.string = this.parseCondition(condition);
    }

    Condition.prototype.toString = function() {
      return this.string;
    };

    Condition.prototype.parseCondition = function(condition) {
      if (!condition) {
        return "";
      }
      if (com.maptimize.Util.isArray(condition)) {
        return this.parseArray(condition);
      } else {
        return this.parseObject(condition);
      }
    };

    Condition.prototype.parseObject = function(object) {
      var property, result, value;
      if (object instanceof Condition || com.maptimize.Util.isString(object)) {
        return object.toString();
      }
      result = new Condition();
      for (property in object) {
        value = object[property];
        if (com.maptimize.Util.isArray(value)) {
          result.appendAnd(property + ' IN ' + this.litteral(value));
        } else {
          result.appendAnd(property + '=' + this.litteral(value));
        }
      }
      return result.toString();
    };

    Condition.prototype.parseArray = function(array) {
      var _this = this;
      return array.shift().replace(/(.)\?/g, function(_, chr) {
        if (chr === '\\') {
          return '?';
        } else {
          return chr + _this.litteral(array.shift());
        }
      });
    };

    Condition.prototype.litteral = function(object) {
      if (com.maptimize.Util.isString(object)) {
        return this.stringLitteral(object);
      }
      if (com.maptimize.Util.isArray(object)) {
        return this.arrayLitteral(object);
      }
      if (com.maptimize.Util.isUndefined(object)) {
        return '';
      } else {
        return String(object);
      }
    };

    Condition.prototype.stringLitteral = function(string) {
      var escapedString;
      ({
        SPECIAL_CHARS: {
          '\b': '\\b',
          '\t': '\\t',
          '\n': '\\n',
          '\f': '\\f',
          '\r': '\\r',
          '\\': '\\\\'
        }
      });
      escapedString = string.replace(/[\x00-\x1f\\]/g, function(chr) {
        if ((__indexOf.call(SPECIAL_CHARS, chr) >= 0)) {
          return SPECIAL_CHARS[chr];
        }
        return '\\u00' + chr.charCodeAt(0).toPaddedString(2, 16);
      });
      return '"' + escapedString.replace(/"/g, '\\"') + '"';
    };

    Condition.prototype.arrayLitteral = function(array) {
      var item, values, _i, _len;
      values = [];
      for (_i = 0, _len = array.length; _i < _len; _i++) {
        item = array[_i];
        values.push(this.litteral(item));
      }
      return "[" + values.join(",") + "]";
    };

    Condition.prototype.appendAnd = function(condition) {
      if (arguments.length > 1) {
        condition = this.toArray(arguments);
      }
      return this.merge("AND", condition);
    };

    Condition.prototype.appendOr = function(condition) {
      if (arguments.length > 1) {
        condition = this.toArray(arguments);
      }
      return this.merge("OR", condition);
    };

    Condition.prototype.merge = function(operator, condition) {
      condition = this.parseCondition(condition);
      if (!this.string) {
        return this.string = condition;
      } else {
        return this.string = "(" + this.string + ")" + operator + "(" + condition + ")";
      }
    };

    Condition.prototype.toArray = function(iterable) {
      return Array.prototype.slice.call(iterable, 0);
    };

    return Condition;

  })();

}).call(this);
(function() {

  com.maptimize.Cache = (function() {

    Cache.name = 'Cache';

    function Cache(map) {
      this.map = map;
      this.mapSystem = map.mapSystem;
      this.bounds = false;
      this.zoom = false;
      this.size = 512;
      this.snap = 256;
    }

    Cache.prototype.setSizeAndSnap = function(size, snap) {
      this.size = size;
      this.snap = snap;
    };

    Cache.prototype.clusterize = function(params, options) {
      if (this.cacheAvailable(params)) {
        return com.maptimize.Util.debug("use cache");
      } else {
        this.computeCacheBounds(params);
        this.zoom = params.zoom;
        params.sw = this.mapSystem.getUrlValue(this.bounds.getSouthWest());
        params.ne = this.mapSystem.getUrlValue(this.bounds.getNorthEast());
        params.action = 'clusterize';
        return new com.maptimize.Request(this.map.getUrl(params.action), params, options).post();
      }
    };

    Cache.prototype.clear = function() {
      return this.bounds = this.zoom = false;
    };

    Cache.prototype.cacheAvailable = function(params) {
      return params.zoom === this.zoom && this.bounds.contains(params.ne) && this.bounds.contains(params.sw);
    };

    Cache.prototype.computeCacheBounds = function(params) {
      var ne, snapNE, snapSW, sw, wholeEarth;
      sw = this.mapSystem.fromLatLngToPixel(params.sw);
      ne = this.mapSystem.fromLatLngToPixel(params.ne);
      snapSW = this.expandPoint(sw, -1);
      snapNE = this.expandPoint(ne, 1);
      this.viewport = this.mapSystem.buildSize(snapNE.x - snapSW.x, snapSW.y - snapNE.y);
      sw = this.mapSystem.fromPixelToLatLng(snapSW);
      ne = this.mapSystem.fromPixelToLatLng(snapNE);
      wholeEarth = this.mapSystem.getLng(sw) >= this.mapSystem.getLng(ne);
      if (this.mapSystem.getLng(sw) >= this.mapSystem.getLng(params.sw) || wholeEarth) {
        sw = this.mapSystem.buildLatLng(this.mapSystem.getLat(sw), -179.999999);
      }
      if (this.mapSystem.getLng(ne) <= this.mapSystem.getLng(params.ne) || wholeEarth) {
        ne = this.mapSystem.buildLatLng(this.mapSystem.getLat(ne), 179.999999);
      }
      return this.bounds = this.mapSystem.buildLatLngBounds(sw, ne);
    };

    Cache.prototype.expandPoint = function(point, factor) {
      return this.mapSystem.buildPoint(this.snapNumber(point.x + factor * this.size, this.snap), this.snapNumber(point.y - factor * this.size, this.snap));
    };

    Cache.prototype.snapNumber = function(number, round) {
      return Math.floor(Math.floor(number / round) * round);
    };

    return Cache;

  })();

}).call(this);
/** 
 *  class com.maptimize.Map
 *  
 *  Class to add maptimize clustering to a Google Maps 
 *
*
*/


(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  com.maptimize.MapController = (function() {

    MapController.name = 'MapController';

    /**
      *  new com.maptimize.Map(googleMap[, options])
      *  ...
    *
    */


    function MapController(mapSystem, options) {
      this.mapSystem = mapSystem;
      if (options == null) {
        options = {};
      }
      this.update = __bind(this.update, this);

      this.refresh = __bind(this.refresh, this);

      this.clusterize = __bind(this.clusterize, this);

      this.mapKey = options.key;
      if (!this.mapKey) {
        alert("may key undefined");
      }
      this.url = options.url || com.maptimize.MAPTIMIZE_URL;
      this.renderer = options.renderer || this.mapSystem.renderer();
      this.active = false;
      this.mapSystem.onIdle(this.clusterize);
      this.points = [];
      this.cache = new com.maptimize.Cache(this);
      this.condition = new com.maptimize.Condition;
      this.groupingDistance = 50;
      this.groupBy = null;
      this.aggregates = null;
      this.properties = null;
      this.jsessionid = false;
      com.maptimize.MapController.WHOLE_EARTH = new this.mapSystem.buildLatLngBounds(new this.mapSystem.buildLatLng(-89.965197, -179.999999), new this.mapSystem.buildLatLng(89.965197, 179.999999));
    }

    MapController.prototype.setCondition = function(condition) {
      this.condition = condition;
    };

    MapController.prototype.setGroupingDistance = function(groupingDistance) {
      this.groupingDistance = groupingDistance;
    };

    MapController.prototype.setGroupBy = function(groupBy) {
      this.groupBy = groupBy;
    };

    MapController.prototype.setClusterAggregates = function(aggregates) {
      if (com.maptimize.Util.isArray(aggregates)) {
        return this.aggregates = aggregates.join(',');
      } else {
        return this.aggregates = aggregates;
      }
    };

    MapController.prototype.setMarkerProperties = function(properties) {
      if (com.maptimize.Util.isArray(properties)) {
        return this.properties = properties.join(',');
      } else {
        return this.properties = properties;
      }
    };

    MapController.prototype.clusterize = function() {
      if (!this.active) {
        return;
      }
      this.mapSystem.fire('maptimize:before:refresh');
      return this.cache.clusterize(this.paramsForRequest(), {
        context: this,
        success: this.update
      });
    };

    MapController.prototype.paramsForRequest = function(bounds) {
      var div, params;
      if (bounds == null) {
        bounds = this.mapSystem.getVisibleBounds();
      }
      div = this.mapSystem.getDiv();
      params = {
        viewport: "" + div.clientWidth + "," + div.clientHeight,
        sw: bounds.getSouthWest(),
        ne: bounds.getNorthEast(),
        condition: this.condition.toString(),
        zoom: this.mapSystem.getZoom(),
        groupingDistance: this.groupingDistance
      };
      if (this.groupBy !== null) {
        params.groupBy = this.groupBy;
      }
      if (this.properties !== null) {
        params.properties = this.properties;
      }
      if (this.aggregates !== null) {
        params.aggregates = this.aggregates;
      }
      return params;
    };

    MapController.prototype.requestBounds = function(callback) {
      var params,
        _this = this;
      params = this.paramsForRequest(com.maptimize.MapController.WHOLE_EARTH);
      params.sw = this.mapSystem.getUrlValue(params.sw);
      params.ne = this.mapSystem.getUrlValue(params.ne);
      params.groupingDistance = 999999;
      return new com.maptimize.Request(this.getUrl("clusterize"), params, {
        success: function(response) {
          var bounds, coords;
          if (response.clusters.length === 1) {
            bounds = response.clusters[0].bounds;
            return callback(_this.mapSystem.buildLatLngBounds(_this.mapSystem.latLngFromString(bounds.sw), _this.mapSystem.latLngFromString(bounds.ne)));
          } else if (response.markers.length === 1) {
            coords = response.markers[0].coords;
            return callback(_this.mapSystem.buildLatLngBounds(_this.mapSystem.latLngFromString(coords), _this.mapSystem.latLngFromString(coords)));
          } else {
            return callback(com.maptimize.MapController.WHOLE_EARTH);
          }
        }
      }).post();
    };

    MapController.prototype.fitBounds = function() {
      var _this = this;
      return this.requestBounds(function(bounds) {
        return _this.mapSystem.fitBounds(bounds);
      });
    };

    MapController.prototype.clear = function() {
      var point, _i, _len, _ref;
      _ref = this.points;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        point = _ref[_i];
        this.renderer.remove(point.marker, this.mapSystem);
      }
      return this.points = [];
    };

    MapController.prototype.refresh = function() {
      this.active = true;
      if (!this.isReady()) {
        com.maptimize.Util.debug("not ready");
        setTimeout(this.refresh, 10);
        return;
      }
      this.cache.clear();
      this.clusterize();
      return this;
    };

    MapController.prototype.update = function(data) {
      var point, pt, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
      this.clear();
      this.jsessionid = data.jsessionid;
      _ref = data.clusters;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        pt = _ref[_i];
        this.points.push(new com.maptimize.Cluster(pt, this));
      }
      _ref1 = data.markers;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        pt = _ref1[_j];
        this.points.push(new com.maptimize.Marker(pt, this));
      }
      _ref2 = this.points;
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        point = _ref2[_k];
        point.marker = this.renderer.add(point, this.mapSystem);
      }
      return this.mapSystem.fire('maptimize:after:refresh');
    };

    MapController.prototype.isReady = function() {
      return this.mapSystem.isReady();
    };

    MapController.prototype.getCount = function() {
      var bounds, count, point, _i, _len, _ref;
      count = 0;
      bounds = this.mapSystem.getBounds();
      _ref = this.points;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        point = _ref[_i];
        if (bounds.intersects(point.bounds)) {
          count += point.count();
        }
      }
      return count;
    };

    MapController.prototype.getUrl = function(action) {
      var url;
      url = "" + this.url + this.mapKey + "/" + action;
      if (this.jsessionid) {
        url += ";jsessionid=" + this.jsessionid;
      }
      return url;
    };

    return MapController;

  })();

}).call(this);
(function() {

  com.maptimize.Marker = (function() {

    Marker.name = 'Marker';

    function Marker(data, map) {
      this.data = data;
      this.map = map;
      this.mapSystem = map.mapSystem;
      if (this.latLng == null) {
        this.latLng = this.mapSystem.latLngFromString(this.data.coords);
      }
      this.bounds = this.mapSystem.buildLatLngBounds(this.latLng, this.latLng);
    }

    Marker.prototype.count = function() {
      return 1;
    };

    Marker.prototype.getProperties = function() {
      return this.data;
    };

    Marker.prototype.id = function() {
      return this.data.id;
    };

    Marker.prototype.ids = function(callback) {
      return callback([this.id()]);
    };

    Marker.prototype.html = function(callback) {
      return new com.maptimize.Request(this.map.getUrl('select'), {
        condition: "id=\"" + this.data.id + "\"",
        limit: 1,
        properties: "id,html"
      }, {
        context: this,
        success: function(response) {
          return callback(response.markers[0].html);
        }
      }).post();
    };

    Marker.prototype.zoomable = function() {
      return false;
    };

    return Marker;

  })();

}).call(this);
(function() {

  com.maptimize.Request = (function() {
    var HEAD, MAX_URL_LENGTH;

    Request.name = 'Request';

    MAX_URL_LENGTH = 2083;

    HEAD = document.getElementsByTagName('HEAD')[0];

    function Request(url, params, options) {
      this.url = url;
      this.params = params;
      this.options = options != null ? options : {};
    }

    Request.prototype.post = function() {
      var abort, abortTimeout, callbackName, callbackParam, context, script, xhr,
        _this = this;
      callbackName = '__maptimize__' + (++Request.REQUEST_ID);
      callbackParam = this.options.callbackParam || 'callback';
      script = document.createElement('script');
      context = this.options.context || null;
      abort = function() {
        HEAD.removeChild(script);
        return delete com.maptimize.Request[callbackName];
      };
      xhr = {
        abort: abort
      };
      abortTimeout = false;
      com.maptimize.Request[callbackName] = function(data) {
        clearTimeout(abortTimeout);
        HEAD.removeChild(script);
        delete com.maptimize.Request[callbackName];
        return _this.options.success.call(context, data);
      };
      script.src = "" + this.url + "?" + callbackParam + "=com.maptimize.Request." + callbackName + "&" + (com.maptimize.Util.queryString(this.params));
      com.maptimize.Util.debug(script.src);
      HEAD.appendChild(script);
      if (this.options.timeout > 0) {
        return abortTimeout = setTimeout(function() {
          xhr.abort();
          return _this.options.error.call(context, xhr, 'timeout');
        }, this.options.timeout);
      }
    };

    return Request;

  })();

  com.maptimize.Request.REQUEST_ID = 0;

}).call(this);
(function() {

  com.maptimize.Util = (function() {
    var clone, debug, extend, isArray, isObject, isString, isUndefined, queryString, rest;
    isUndefined = function(obj) {
      return typeof obj === 'undefined';
    };
    isArray = Array.isArray || function(obj) {
      return Object.prototype.toString.call(obj) === '[object Array]';
    };
    isString = function(obj) {
      return Object.prototype.toString.call(obj) === '[object String]';
    };
    isObject = function(obj) {
      return obj === Object(obj);
    };
    extend = function(obj) {
      var key, source, val, _i, _len, _ref;
      _ref = rest(arguments);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        source = _ref[_i];
        for (key in source) {
          val = source[key];
          obj[key] = val;
        }
      }
      return obj;
    };
    clone = function(obj) {
      var cloneObj, key, value;
      if (isArray(obj)) {
        return obj.slice(0);
      } else {
        if (isObject(obj)) {
          cloneObj = {};
          for (key in obj) {
            value = obj[key];
            cloneObj[key] = clone(value);
          }
          return cloneObj;
        } else {
          return obj;
        }
      }
    };
    rest = function(array, index, guard) {
      return Array.prototype.slice.call(array, isUndefined(index) || guard ? 1 : index);
    };
    queryString = function(params) {
      var key, p, pairs, properties, property, value, _i, _j, _len, _len1, _ref;
      properties = [];
      pairs = [];
      for (key in params) {
        value = params[key];
        properties.push(key);
      }
      properties.sort();
      for (_i = 0, _len = properties.length; _i < _len; _i++) {
        property = properties[_i];
        if (isArray(params[property])) {
          _ref = params[property];
          for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
            p = _ref[_j];
            pairs.push("" + property + "=" + (encodeURIComponent(p)));
          }
        } else {
          pairs.push("" + property + "=" + (encodeURIComponent(params[property])));
        }
      }
      return pairs.join("&");
    };
    debug = function() {
      if (typeof console !== "undefined" && typeof console.debug !== "undefined") {
        return console.debug.apply(console, ["Maptimize:"].concat(Array.prototype.slice.call(arguments, 0)));
      }
    };
    return {
      extend: extend,
      clone: clone,
      isUndefined: isUndefined,
      isArray: isArray,
      isString: isString,
      queryString: queryString,
      debug: debug
    };
  })();

}).call(this);
(function() {
  var __slice = [].slice;

  com.maptimize.AbstractMap = (function() {

    AbstractMap.name = 'AbstractMap';

    function AbstractMap() {
      throw "com.maptimize.AbstractMap cannot be instanciate";
    }

    AbstractMap.prototype.on = function(eventName, callback, object) {
      throw new Error("com.maptimize.AbstractMap#on not implemented");
    };

    AbstractMap.prototype.off = function(eventName, callback, object) {
      throw new Error("com.maptimize.AbstractMap#off not implemented");
    };

    AbstractMap.prototype.fire = function() {
      var args, eventName, object, _i;
      eventName = arguments[0], args = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), object = arguments[_i++];
      throw new Error("com.maptimize.AbstractMap#fire not implemented");
    };

    AbstractMap.prototype.onIdle = function(callback) {
      throw new Error("com.maptimize.AbstractMap#onIdle not implemented");
    };

    AbstractMap.prototype.buildLatLng = function(lat, lng) {
      throw new Error("com.maptimize.AbstractMap#buildLatLng not implemented");
    };

    AbstractMap.prototype.buildLatLngBounds = function(sw, ne) {
      throw new Error("com.maptimize.AbstractMap#buildLatLngBounds not implemented");
    };

    AbstractMap.prototype.buildSize = function(width, height) {
      throw new Error("com.maptimize.AbstractMap#buildSize not implemented");
    };

    AbstractMap.prototype.buildPoint = function(x, y) {
      throw new Error("com.maptimize.AbstractMap#buildPoint not implemented");
    };

    AbstractMap.prototype.latLngFromString = function(string) {
      var lat, lng, _ref;
      _ref = string.split(','), lat = _ref[0], lng = _ref[1];
      return this.buildLatLng(lat, lng);
    };

    AbstractMap.prototype.getLat = function(latLng) {
      throw new Error("com.maptimize.AbstractMap#getLat not implemented");
    };

    AbstractMap.prototype.getLng = function(latLng) {
      throw new Error("com.maptimize.AbstractMap#getLng not implemented");
    };

    AbstractMap.prototype.getUrlValue = function(latLng, delta) {
      if (delta == null) {
        delta = 0;
      }
      return "" + (this.getLat(latLng) + delta) + "," + (this.getLng(latLng) + delta);
    };

    AbstractMap.prototype.fromLatLngToPixel = function(latLng) {
      throw new Error("com.maptimize.AbstractMap#fromLatLngToPixel not implemented");
    };

    AbstractMap.prototype.fromPixelToLatLng = function(point) {
      throw new Error("com.maptimize.AbstractMap#fromPixelToLatLng not implemented");
    };

    AbstractMap.prototype.getBounds = function() {
      throw new Error("com.maptimize.AbstractMap#getBounds not implemented");
    };

    AbstractMap.prototype.getZoom = function() {
      throw new Error("com.maptimize.AbstractMap#getZoom not implemented");
    };

    AbstractMap.prototype.getDiv = function() {
      throw new Error("com.maptimize.AbstractMap#getDiv not implemented");
    };

    AbstractMap.prototype.fitBounds = function(bounds) {
      throw new Error("com.maptimize.AbstractMap#fitBounds not implemented");
    };

    AbstractMap.prototype.renderer = function() {
      throw new Error("com.maptimize.AbstractMap#renderer not implemented");
    };

    AbstractMap.prototype.isReady = function() {
      throw new Error("com.maptimize.AbstractMap#isReady not implemented");
    };

    AbstractMap.prototype.getVisibleBounds = function() {
      throw new Error("com.maptimize.AbstractMap#getVisibleBounds not implemented");
    };

    return AbstractMap;

  })();

}).call(this);
(function() {

  L.MarkerWithLabel = L.Marker.extend({
    options: {
      title: '',
      clickable: true,
      draggable: false,
      zIndexOffset: 0,
      className: 'leaflet-marker-label',
      offset: function(el) {
        return {
          x: -(el.offsetWidth / 2),
          y: -(el.offsetHeight / 2)
        };
      }
    },
    initialize: function(_latlng, label, options) {
      this._latlng = _latlng;
      this.label = label;
      if (options == null) {
        options = {};
      }
      L.Util.setOptions(this, options);
      return this.options.title = this.label;
    },
    _initIcon: function() {
      if (!this._icon) {
        this._icon = L.DomUtil.create('div', "leaflet-marker-icon " + this.options.className);
        this._icon.innerHTML = this.label;
        if (this.options.title) {
          this._icon.title = this.options.title;
        }
        this._initInteraction();
      }
      return this._map._panes.markerPane.appendChild(this._icon);
    },
    _reset: function() {
      var offset, pos;
      pos = this._map.latLngToLayerPoint(this._latlng).round();
      offset = this.options.offset(this._icon);
      pos.x = pos.x + offset.x;
      pos.y = pos.y + offset.y;
      L.DomUtil.setPosition(this._icon, pos);
      return this._icon.style.zIndex = pos.y + this.options.zIndexOffset;
    }
  });

}).call(this);
(function() {

  com.maptimize.LeafletRenderer = (function() {
    var add, click, remove;
    add = function(point, mapSystem) {
      var count, marker, options, size;
      count = point.count();
      size = ("" + count).length;
      options = {
        title: count,
        clickable: true
      };
      if (point.zoomable()) {
        options.className = "maptimize_cluster maptimize_cluster_" + (size - 1);
      } else {
        options.offset = function(el) {
          return {
            x: -(el.offsetWidth / 2),
            y: -el.offsetHeight
          };
        };
        options.className = "maptimize_marker maptimize_marker_" + (size - 1);
      }
      marker = new L.MarkerWithLabel(point.latLng, count, options);
      mapSystem.lmap.addLayer(marker);
      marker.on('click', (function(e) {
        return click(point, mapSystem);
      }));
      return marker;
    };
    remove = function(marker, mapSystem) {
      return mapSystem.lmap.removeLayer(marker);
    };
    click = function(point, mapSystem) {
      var zoom;
      zoom = mapSystem.getZoom();
      if (point.zoomable && point.zoomable() && zoom < mapSystem.maxZoom()) {
        mapSystem.fitBounds(point.bounds);
      } else {
        point.html(function(html) {
          return point.marker.bindPopup("<div class='maptimize_window'>" + html + "</div>").openPopup();
        });
      }
      return false;
    };
    return {
      add: add,
      remove: remove
    };
  })();

}).call(this);
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  com.maptimize.Leaflet = (function(_super) {

    __extends(Leaflet, _super);

    Leaflet.name = 'Leaflet';

    function Leaflet(lmap, rendererClass) {
      this.lmap = lmap;
      this.rendererClass = rendererClass != null ? rendererClass : com.maptimize.LeafletRenderer;
    }

    Leaflet.prototype.on = function(eventName, callback, object) {
      if (object == null) {
        object = this.lmap;
      }
      return object.on(eventName, callback);
    };

    Leaflet.prototype.off = function(eventName, callback, object) {
      if (object == null) {
        object = this.lmap;
      }
      return object.off(object, eventName, callback);
    };

    Leaflet.prototype.fire = function() {
      var args, eventName, object, _i;
      eventName = arguments[0], args = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), object = arguments[_i++];
      if (object == null) {
        object = this.lmap;
      }
      return object.fire(eventName, args);
    };

    Leaflet.prototype.onIdle = function(callback) {
      this.on('moveend', callback);
      return this.on('dragend', callback);
    };

    Leaflet.prototype.buildLatLng = function(lat, lng) {
      return new L.LatLng(lat, lng);
    };

    Leaflet.prototype.buildLatLngBounds = function(sw, ne) {
      return new L.LatLngBounds(sw, ne);
    };

    Leaflet.prototype.buildSize = function(width, height) {
      return new L.Point(width, height);
    };

    Leaflet.prototype.buildPoint = function(x, y) {
      return new L.Point(x, y);
    };

    Leaflet.prototype.getLat = function(latLng) {
      return latLng.lat;
    };

    Leaflet.prototype.getLng = function(latLng) {
      return latLng.lng;
    };

    Leaflet.prototype.maxZoom = function() {
      return this.lmap.getMaxZoom();
    };

    Leaflet.prototype.fromLatLngToPixel = function(latLng) {
      return this.lmap.latLngToLayerPoint(latLng);
    };

    Leaflet.prototype.fromPixelToLatLng = function(point) {
      return this.lmap.layerPointToLatLng(point);
    };

    Leaflet.prototype.getBounds = function() {
      return this.lmap.getBounds();
    };

    Leaflet.prototype.getVisibleBounds = function() {
      return this.getBounds();
    };

    Leaflet.prototype.getZoom = function() {
      return this.lmap.getZoom();
    };

    Leaflet.prototype.getDiv = function() {
      return this.lmap._container;
    };

    Leaflet.prototype.fitBounds = function(bounds) {
      return this.lmap.fitBounds(bounds);
    };

    Leaflet.prototype.renderer = function() {
      return this.rendererClass;
    };

    Leaflet.prototype.isReady = function() {
      return true;
    };

    return Leaflet;

  })(com.maptimize.AbstractMap);

}).call(this);
