class Context:
    def __init__(self):
        # Initialize an internal store for attributes
        self.__dict__["_store"] = {}

    def __getattr__(self, name):
        return self._store.get(name)

    def __setattr__(self, name, value):
        self._store[name] = value

    def __delattr__(self, name):
        if name in self._store:
            del self._store[name]
