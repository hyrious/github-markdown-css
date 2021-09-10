all: make.js temp.html

make.js: make.jsx
	esbuild make.jsx --bundle --outfile=make.js --jsx-factory=jsx --jsx-fragment=Fragment --inject:./inject.js --sourcemap=inline --sources-content=false

temp.html: make.rb
	ruby make.rb -q
