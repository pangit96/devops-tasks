from setuptools import setup

# reading long description from file
with open('README.md') as file:
    long_description = file.read()


# specify requirements of your package here
REQUIREMENTS = ['docopt==0.6.2','awscli', 'boto3' ]

# calling the setup function
setup(name='playment-cli',
    version='1.0.0',
    description='Playment CLI',
    long_description=long_description,
    author='Utkarsh Pandit',
    author_email='pandit.utkarsh14@gmail.com',
    packages=['cli'],
    include_package_data=True,
    install_requires=REQUIREMENTS,
    python_requires='>=3',
    entry_points={
        "console_scripts": [
            "playment=cli.playment:main"
        ]
    }
)
