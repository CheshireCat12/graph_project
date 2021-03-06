from glob import glob
from xmltodict import parse


cdef class LoaderTrainTestValSplit:

    def __init__(self, str folder_dataset):
        self.folder_dataset = folder_dataset
        self.__EXTENSION = '.cxl'

    cdef list _init_splits(self, str filename):
        cdef list data = []

        split_file = glob(f'{self.folder_dataset}{filename}{self.__EXTENSION}')[0]

        with open(split_file) as file:
            split_text = "".join(file.readlines())

        parsed_data = parse(split_text)
        index = 'fingerprints'
        if 'Mutagenicity' in self.folder_dataset:
            index = 'mutagenicity'
        splits = parsed_data['GraphCollection'][index]['print']

        for split in splits:
            data.append((split['@file'], split['@class']))

        return data


    cpdef list load_train_split(self):
        """
        Gather the training set.
        It returns a list of tuple containing the data and their corresponding labels
        
        :return: list((data, label)) 
        """
        return self._init_splits('train')

    cpdef list load_test_split(self):
        """
        Gather the test set.
        It returns a list of tuple containing the data and their corresponding labels

        :return: list((data, label)) 
        """
        return self._init_splits('test')

    cpdef list load_val_split(self):
        """
        Gather the validation set.
        It returns a list of tuple containing the data and their corresponding labels

        :return: list((data, label)) 
        """
        return self._init_splits('validation')