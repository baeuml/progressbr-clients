Clients for the progressbr web service.

Basic Usage
-----------

Create new progress bar (with range 0-100)::

    uuid=$(cli/pbr create 100)

Update progress::

    # ... (do some work)
    cli/pbr update $uuid 0 10

    # ... (do some more work)
    cli/pbr update $uuid 10 20
    
    # ...

You can check the progress at the following url::

    http://progressbr.herokuapp.com/progress/<uuid>

