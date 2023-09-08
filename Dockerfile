# Use the mageai/mageai:latest base image
FROM mageai/mageai:latest

ARG PROJECT_NAME=demo_project
ARG MAGE_CODE_PATH=/home/mage_code
ARG USER_CODE_PATH=${MAGE_CODE_PATH}/$demo_project

WORKDIR ${MAGE_CODE_PATH}

# Replace [project_name] with the name of your project (e.g. demo_project)
COPY $demo_project $demo_project

# Set the USER_CODE_PATH variable to the path of user project.
# The project path needs to contain project name.
# Replace [project_name] with the name of your project (e.g. demo_project)
ENV USER_CODE_PATH=${USER_CODE_PATH}

COPY demo_project/pipelines/etl_demo/metadata.yaml /home/mage_code/metadata.yaml
RUN groupadd -r mage && useradd -r -g mage mage

# Change ownership to mage user for entire directory
RUN chown -R mage:mage /home/mage_code

# Adjust file permissions
RUN chmod 664 /home/mage_code/metadata.yaml

# Install custom Python libraries
RUN pip3 install --no-cache-dir -r ${USER_CODE_PATH}/requirements.txt

# Install custom libraries within 3rd party libraries (e.g. dbt packages)
RUN python3 /app/install_other_dependencies.py --path ${USER_CODE_PATH}

ENV PYTHONPATH="${PYTHONPATH}:/home/mage_code"

USER mage

CMD ["/bin/sh", "-c", "/app/run_app.sh"]