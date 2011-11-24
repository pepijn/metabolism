(function() {
  var Enzyme, Molecule, Unit, cell, elname, enzyme, list, molecule, name, template;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  window.enzymes = {};

  window.molecules = [];

  template = {
    enzyme: $('.enzyme'),
    molecule: $('.molecule')
  };

  cell = {
    cytoplasm: $('#cytoplasm')
  };

  list = {
    'Hexokinase': {
      substrates: ['Glucose', 'ATP'],
      products: ['Glucose 6-phosphate', 'ADP']
    },
    'Phosphoglucose isomerase': {
      substrates: 'Glucose 6-phosphate',
      products: 'Fructose 6-phosphate'
    },
    'Phosphofructokinase-1': {
      substrates: ['Fructose 6-phosphate', 'ATP'],
      products: ['Fructose 1,6-biphosphate', 'ADP']
    },
    'Aldolase': {
      substrates: 'Fructose 1,6-biphosphate',
      products: ['Dihydroxyacetone phosphate', 'Glyceraldehyde 3-phosphate']
    }
  };

  elname = function(element) {
    return element.text().replace(/^\s+|\s+$/g, '');
  };

  molecule = function(element) {
    return window.molecules[element.attr('id').replace('molecule-', '')];
  };

  Unit = (function() {

    function Unit() {
      this.id = this.name.toLowerCase().replace(' ', '-');
    }

    Unit.prototype.build = function(template) {
      return template.clone().attr('id', this.id).text(this.name).appendTo(cytoplasm);
    };

    return Unit;

  })();

  Enzyme = (function() {

    __extends(Enzyme, Unit);

    function Enzyme(name, substrates, products) {
      this.name = name;
      Enzyme.__super__.constructor.call(this);
      this.substrates = _.flatten([substrates]);
      this.products = _.flatten([products]);
      this.bindings = [];
    }

    Enzyme.prototype.accepts = function(substrate) {
      if (_.include(_.difference(this.substrates, this.molecules()), substrate.name)) {
        return true;
      }
    };

    Enzyme.prototype.bind = function(molecule) {
      if (this.accepts(molecule)) {
        molecule.bind();
        this.bindings.push(molecule);
        return this.react();
      }
    };

    Enzyme.prototype.molecules = function() {
      return _.map(this.bindings, function(molecule) {
        return molecule.name;
      });
    };

    Enzyme.prototype.react = function() {
      var index, molecule, product, _i, _len, _ref, _results;
      if (this.bindings.length === this.substrates.length) {
        this.bindings.push(this.bindings[0].clone());
        _ref = this.bindings;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          molecule = _ref[_i];
          index = _.indexOf(this.substrates, molecule.name);
          product = this.products[index];
          _results.push(molecule.release(product));
        }
        return _results;
      }
    };

    return Enzyme;

  })();

  Molecule = (function() {

    __extends(Molecule, Unit);

    function Molecule(name) {
      var number;
      this.name = name;
      number = window.molecules.length;
      window.molecules.push(this);
      this.id = 'molecule-' + number;
      this.element = this.build(template.molecule);
    }

    Molecule.prototype.bind = function() {
      return this.element.draggable('disable');
    };

    Molecule.prototype.release = function(name) {
      this.name = name;
      this.element.text(this.name);
      this.element.effect('highlight');
      return this.element.draggable('enable');
    };

    return Molecule;

  })();

  for (name in list) {
    enzyme = list[name];
    enzyme = new Enzyme(name, enzyme.substrates, enzyme.products);
    window.enzymes[enzyme.id] = enzyme;
    enzyme.build(template.enzyme).droppable({
      accept: ".molecule",
      hoverClass: "hover",
      activate: function(event, ui) {
        enzyme = enzymes[$(this).attr('id')];
        if (enzyme.accepts(molecule(ui.draggable))) {
          return $(this).addClass('active');
        }
      },
      deactivate: function() {
        return $(this).removeClass('active');
      },
      drop: function(event, ui) {
        enzyme = enzymes[$(this).attr('id')];
        return enzyme.bind(molecule(ui.draggable));
      }
    });
  }

  new Molecule("Glucose");

  new Molecule("ATP");

  new Molecule("Fructose 1,6-biphosphate");

  new Molecule("ATP");

  $('.molecule').draggable();

}).call(this);
