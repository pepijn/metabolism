(function() {
  var Enzyme, Unit, cell, enzyme, list, molecule, name, template;
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
    },
    'Triose phosphate isomerase': {
      substrates: ['Dihydroxyacetone phosphate'],
      products: ['Glyceraldehyde 3-phosphate']
    },
    'Glyceraldehyde-3-phosphate dehydrogenase': {
      substrates: ['Glyceraldehyde 3-phosphate', 'Pi', 'NAD+'],
      products: ['1,3-bisphosphate glycerate', 'NADH']
    },
    'Phosphoglycerate kinase': {
      substrates: ['1,3-bisphosphate glycerate', 'ADP'],
      products: ['3-phosphoglycerate', 'ATP']
    },
    'Phosphoglycerate mutase': {
      substrates: '3-phosphoglycerate',
      products: '2-phosphoglycerate'
    },
    'Enolase': {
      substrates: '2-phosphoglycerate',
      products: ['Phosphoenolpyruvate', 'H2O']
    },
    'Pyruvate kinase': {
      substrates: ['Phosphoenolpyruvate', 'ADP'],
      products: ['Pyruvate', 'ATP']
    }
  };

  molecule = function(element) {
    return element.text().replace(/^\s+|\s+$/g, '');
  };

  Unit = (function() {

    function Unit() {
      this.id = this.name.toLowerCase().replace(' ', '-');
    }

    Unit.prototype.build = function(template) {
      this.element = template.clone().attr('id', this.id).text(this.name);
      return this.element.appendTo(cytoplasm);
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
      return _.include(_.difference(this.substrates, this.molecules()), molecule(substrate));
    };

    Enzyme.prototype.bind = function(molecule) {
      if (this.accepts(molecule)) {
        this.bindings.push(molecule);
        molecule.draggable('disable');
        this.element.addClass('occupied');
        return this.react();
      }
    };

    Enzyme.prototype.molecules = function() {
      return _.map(this.bindings, function(element) {
        return molecule(element);
      });
    };

    Enzyme.prototype.react = function() {
      var binding, product, _i, _j, _len, _len2, _ref, _ref2;
      if (this.bindings.length === this.substrates.length) {
        _ref = this.products;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          product = _ref[_i];
          binding = _i >= this.bindings.length ? this.bindings[0] : this.bindings[_i];
          product = binding.clone().appendTo(binding.parent()).text(product);
          $('.molecule').removeClass('ui-draggable-disabled').draggable();
          product.effect('highlight');
        }
        _ref2 = this.bindings;
        for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
          binding = _ref2[_j];
          binding.hide('puff');
        }
        this.bindings = [];
        this.element.effect('highlight');
        return this.element.removeClass('occupied');
      }
    };

    return Enzyme;

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
        if (enzyme.accepts(ui.draggable)) return $(this).addClass('active');
      },
      deactivate: function() {
        return $(this).removeClass('active');
      },
      drop: function(event, ui) {
        enzyme = enzymes[$(this).attr('id')];
        return enzyme.bind(ui.draggable);
      }
    });
  }

  $('.molecule').draggable();

}).call(this);
